function [loadNorm,throughputNorm,packetLossRatio] = irsa(sourceNumber,randomAccessFrameLength,packetReadyProb,maxRepetitionRate,simulationTime,maxIter)
% This function simulates a specific IRSA scenario with a given number of
% users, random access frame (RAF) length, degree distribution, and number
% of RAFs. As results, it gives normalized load, normalized throughput
% and Packet Loss Rate.

% +++ Inputs
%     - sourceNumber: Number of users
%     - randomAccessFrameLength: How many slots has one IRSA frame?
%     - packetReadyProb: The probabiliy of a user being active in a frame
%     - maxRepetitionRate: defines the degree distribution 
%             - 2.3: 0.7x^2 + 0.3x^3 defined by MG, CM
%             - 3: x^3 defined by MG, CM
%             - 4: 0.5102x^2 + 0.4898x^4 from G. Liva
%             - 5: 0.5631x^2 + 0.0436x^3 + 0.3933x^5 from G. Liva
%             - 6: 0.5465x^2 + 0.1623x^3 + 0.2912x^6 from G. Liva
%             - 8: 0.5x^2 + 0.28x^3 + 0.22x^8 from G. Liva
%             - otherwise: 0.4977x^2 + 0.2207x^3 + 0.0381x^4 + 0.0756x^5 + 0.0398x^6 ...
%                 + 0.0009x^7 + 0.0088x^8 + 0.0068x^9 + 0.0030x^11 + 0.0429x^14 + 0.0081x^15 + 0.0576x^16 from G. Liva
%     - simulationTime: total number of Random Access frames during simulation
%           Because the function gives the normalized performance metrics,
%           the increasing simulationTime leads to an experimental average.
%     - maxIter: Limit the max number of iterations of SIC if exists
%           Otherwise, SIC iterates until a stopping set occurs (complete SIC)
% 
% +++ Outputs
%     - loadNorm: Normalized Load
%     - throughputNorm: Normalized Throughput
%     - packetLossRatio: Packet Loss Rate
    
    
validateattributes(sourceNumber,{'numeric'},{'scalar','integer','positive','>' 2},mfilename,'sourceNumber',1)
validateattributes(randomAccessFrameLength,{'numeric'},{'scalar','integer','positive','>' 2},mfilename,'randomAccessFrameLength',2)
validateattributes(packetReadyProb,{'numeric'},{'scalar','real','>=', 0,'<=',1},mfilename,'packetReadyProb',3)
%validateattributes(maxRepetitionRate,{'numeric'},{'scalar','integer','positive','<' randomAccessFrameLength},mfilename,'maxRepetitionRate',4)
assert(ismember(maxRepetitionRate,[2.3,3,4,5,6,8,16]),'The maximum repetition rate shall be equal to one of the following values: 4,5,6,8,16.')
validateattributes(simulationTime,{'numeric'},{'scalar','integer','positive'},mfilename,'simulationTime',5)
if exist('maxIter','var') % complete SIC
    validateattributes(maxIter,{'numeric'},{'integer','positive'},mfilename,'maximum SIC iterations',6)
end

ackdPacketCount = 0;
pcktTransmissionAttempts = 0;
pcktCollisionCount = 0;
sourceStatus = zeros(1,sourceNumber);
sourceBackoff = zeros(1,sourceNumber);
% legit source statuses are always non-negative integers and equal to:
% 0: source has no packet ready to be transmitted (is idle)
% 1: source has a packet ready to be transmitted, either because new data must be sent or a previously collided packet has waited the backoff time
% 2: source is backlogged due to previous packets collision
pcktGenerationTimestamp = zeros(1,sourceNumber);
currentRAF = 0;

if ~exist('maxIter','var')
%     warning('Performing complete interference cancellation.')
end

while currentRAF < simulationTime
    randomAccessFrame = zeros(sourceNumber,randomAccessFrameLength);
%     CM: A matrix with row number of active user and coloumn number of IRSA slot number
%     If one user sends a packet in a specific slot, we will write 1 in the corresponding element
%     of matrix randomAccessFrame. We will write 0 otherwise.
    twinsOverhead = cell(sourceNumber,randomAccessFrameLength);
%     CM: In IRSA, each user writes the slot position of its all replicas to the packets as Overhead
%     twinsOverhead represents the overheads of all packets in the RAF
%     For each user (row), we write the slot positions of its replicas to all slots, it send a replica in.
    currentRAF = currentRAF + 1;

    for eachSource1 = 1:sourceNumber % create the RAF
        if sourceStatus(1,eachSource1) == 0 && rand(1) <= packetReadyProb % new packet
            sourceStatus(1,eachSource1) = 1;
            pcktGenerationTimestamp(1,eachSource1) = currentRAF;
            pcktRepetitionExp = rand(1);
            switch maxRepetitionRate
                case 2.3
                    if pcktRepetitionExp <= 0.7
                        % genera 2 repliche
                        [pcktTwins,rafRow] = generateTwins(randomAccessFrameLength,2);
                        randomAccessFrame(eachSource1,pcktTwins) = 1;
                        twinsOverhead(eachSource1,:) = rafRow;
                    elseif pcktRepetitionExp <= (0.7 + 0.3) 
                        % genera 3 repliche
                        [pcktTwins,rafRow] = generateTwins(randomAccessFrameLength,3);
                        randomAccessFrame(eachSource1,pcktTwins) = 1;
                        twinsOverhead(eachSource1,:) = rafRow;
                    end
                case 3
                    % genera 3 repliche
                    [pcktTwins,rafRow] = generateTwins(randomAccessFrameLength,3);
                    randomAccessFrame(eachSource1,pcktTwins) = 1;
                    twinsOverhead(eachSource1,:) = rafRow;
                case 4
                    if pcktRepetitionExp <= 0.5102
                        % genera 2 repliche
                        [pcktTwins,rafRow] = generateTwins(randomAccessFrameLength,2);
                        randomAccessFrame(eachSource1,pcktTwins) = 1;
                        twinsOverhead(eachSource1,:) = rafRow;
                    elseif pcktRepetitionExp <= (0.5102 + 0.4898)
                        % genera 4 repliche
                        [pcktTwins,rafRow] = generateTwins(randomAccessFrameLength,4);
                        randomAccessFrame(eachSource1,pcktTwins) = 1;
                        twinsOverhead(eachSource1,:) = rafRow;
                    end
                case 5
                    if pcktRepetitionExp <= 0.5631
                        % genera 2 repliche
                        [pcktTwins,rafRow] = generateTwins(randomAccessFrameLength,2);
                        randomAccessFrame(eachSource1,pcktTwins) = 1;
                        twinsOverhead(eachSource1,:) = rafRow;
                    elseif pcktRepetitionExp <= (0.5631 + 0.0436)
                        % genera 3 repliche
                        [pcktTwins,rafRow] = generateTwins(randomAccessFrameLength,4);
                        randomAccessFrame(eachSource1,pcktTwins) = 1;
                        twinsOverhead(eachSource1,:) = rafRow;
                    elseif pcktRepetitionExp <= (0.5631 + 0.0436 + 0.3933)
                        % genera 5 repliche
                        [pcktTwins,rafRow] = generateTwins(randomAccessFrameLength,5);
                        randomAccessFrame(eachSource1,pcktTwins) = 1;
                        twinsOverhead(eachSource1,:) = rafRow;
                    end
                case 6
                    if pcktRepetitionExp <= 0.5465
                        % genera 2 repliche
                        [pcktTwins,rafRow] = generateTwins(randomAccessFrameLength,2);
                        randomAccessFrame(eachSource1,pcktTwins) = 1;
                        twinsOverhead(eachSource1,:) = rafRow;
                    elseif pcktRepetitionExp <= (0.5465 + 0.1623)
                        % genera 3 repliche
                        [pcktTwins,rafRow] = generateTwins(randomAccessFrameLength,3);
                        randomAccessFrame(eachSource1,pcktTwins) = 1;
                        twinsOverhead(eachSource1,:) = rafRow;
                    elseif pcktRepetitionExp <= (0.5465 + 0.1623 + 0.2912)
                        % genera 6 repliche
                        [pcktTwins,rafRow] = generateTwins(randomAccessFrameLength,6);
                        randomAccessFrame(eachSource1,pcktTwins) = 1;
                        twinsOverhead(eachSource1,:) = rafRow;
                    end
                case 8
                    if pcktRepetitionExp <= 0.5
                        % genera 2 repliche
                        [pcktTwins,rafRow] = generateTwins(randomAccessFrameLength,2);
                        randomAccessFrame(eachSource1,pcktTwins) = 1;
                        twinsOverhead(eachSource1,:) = rafRow;
                    elseif pcktRepetitionExp <= (0.5 + 0.28)
                        % genera 3 repliche
                        [pcktTwins,rafRow] = generateTwins(randomAccessFrameLength,3);
                        randomAccessFrame(eachSource1,pcktTwins) = 1;
                        twinsOverhead(eachSource1,:) = rafRow;
                    elseif pcktRepetitionExp <= (0.5 + 0.28 + 0.22)
                        % genera 8 repliche
                        [pcktTwins,rafRow] = generateTwins(randomAccessFrameLength,8);
                        randomAccessFrame(eachSource1,pcktTwins) = 1;
                        twinsOverhead(eachSource1,:) = rafRow;
                    end
                otherwise % case 16
                    if pcktRepetitionExp <= 0.4977
                        % genera 2 repliche
                        [pcktTwins,rafRow] = generateTwins(randomAccessFrameLength,2);
                        randomAccessFrame(eachSource1,pcktTwins) = 1;
                        twinsOverhead(eachSource1,:) = rafRow;
                    elseif pcktRepetitionExp <= (0.4977 + 0.2207)
                        % genera 3 repliche
                        [pcktTwins,rafRow] = generateTwins(randomAccessFrameLength,3);
                        randomAccessFrame(eachSource1,pcktTwins) = 1;
                        twinsOverhead(eachSource1,:) = rafRow;
                    elseif pcktRepetitionExp <= (0.4977 + 0.2207 + 0.0381)
                        % genera 4 repliche
                        [pcktTwins,rafRow] = generateTwins(randomAccessFrameLength,4);
                        randomAccessFrame(eachSource1,pcktTwins) = 1;
                        twinsOverhead(eachSource1,:) = rafRow;
                    elseif pcktRepetitionExp <= (0.4977 + 0.2207 + 0.0381 + 0.0756)
                        % genera 5 repliche
                        [pcktTwins,rafRow] = generateTwins(randomAccessFrameLength,5);
                        randomAccessFrame(eachSource1,pcktTwins) = 1;
                        twinsOverhead(eachSource1,:) = rafRow;
                    elseif pcktRepetitionExp <= (0.4977 + 0.2207 + 0.0381 + 0.0756 + 0.0398)
                        % genera 6 repliche
                        [pcktTwins,rafRow] = generateTwins(randomAccessFrameLength,6);
                        randomAccessFrame(eachSource1,pcktTwins) = 1;
                        twinsOverhead(eachSource1,:) = rafRow;
                    elseif pcktRepetitionExp <= (0.4977 + 0.2207 + 0.0381 + 0.0756 + 0.0398 + 0.0009)
                        % genera 7 repliche
                        [pcktTwins,rafRow] = generateTwins(randomAccessFrameLength,7);
                        randomAccessFrame(eachSource1,pcktTwins) = 1;
                        twinsOverhead(eachSource1,:) = rafRow;
                    elseif pcktRepetitionExp <= (0.4977 + 0.2207 + 0.0381 + 0.0756 + 0.0398 + 0.0009 + 0.0088)
                        % genera 8 repliche
                        [pcktTwins,rafRow] = generateTwins(randomAccessFrameLength,8);
                        randomAccessFrame(eachSource1,pcktTwins) = 1;
                        twinsOverhead(eachSource1,:) = rafRow;
                    elseif pcktRepetitionExp <= (0.4977 + 0.2207 + 0.0381 + 0.0756 + 0.0398 + 0.0009 + 0.0088 + 0.0068)
                        % genera 9 repliche
                        [pcktTwins,rafRow] = generateTwins(randomAccessFrameLength,9);
                        randomAccessFrame(eachSource1,pcktTwins) = 1;
                        twinsOverhead(eachSource1,:) = rafRow;
                    elseif pcktRepetitionExp <= (0.4977 + 0.2207 + 0.0381 + 0.0756 + 0.0398 + 0.0009 + 0.0088 + 0.0068 + 0.0030)
                        % genera 11 repliche
                        [pcktTwins,rafRow] = generateTwins(randomAccessFrameLength,11);
                        randomAccessFrame(eachSource1,pcktTwins) = 1;
                        twinsOverhead(eachSource1,:) = rafRow;
                    elseif pcktRepetitionExp <= (0.4977 + 0.2207 + 0.0381 + 0.0756 + 0.0398 + 0.0009 + 0.0088 + 0.0068 + 0.0030 + 0.0429)
                        % genera 14 repliche
                        [pcktTwins,rafRow] = generateTwins(randomAccessFrameLength,14);
                        randomAccessFrame(eachSource1,pcktTwins) = 1;
                        twinsOverhead(eachSource1,:) = rafRow;
                    elseif pcktRepetitionExp <= (0.4977 + 0.2207 + 0.0381 + 0.0756 + 0.0398 + 0.0009 + 0.0088 + 0.0068 + 0.0030 + 0.0429 + 0.0081)
                        % genera 15 repliche
                        [pcktTwins,rafRow] = generateTwins(randomAccessFrameLength,15);
                        randomAccessFrame(eachSource1,pcktTwins) = 1;
                        twinsOverhead(eachSource1,:) = rafRow;
                    elseif pcktRepetitionExp <= (0.4977 + 0.2207 + 0.0381 + 0.0756 + 0.0398 + 0.0009 + 0.0088 + 0.0068 + 0.0030 + 0.0429 + 0.0081 + 0.0576)
                        % genera 16 repliche
                        [pcktTwins,rafRow] = generateTwins(randomAccessFrameLength,16);
                        randomAccessFrame(eachSource1,pcktTwins) = 1;
                        twinsOverhead(eachSource1,:) = rafRow;
                    end
            end
        % elseif sourceStatus(1,eachSource1) == 1 % backlogged source
        %     firstReplicaSlot = randi(randomAccessFrameLength);
        %     secondReplicaSlot = randi(randomAccessFrameLength);
        %     while secondReplicaSlot == firstReplicaSlot
        %         secondReplicaSlot = randi(randomAccessFrameLength);
        %     end
        %     randomAccessFrame(eachSource1,firstReplicaSlot) = secondReplicaSlot;
        %     randomAccessFrame(eachSource1,secondReplicaSlot) = firstReplicaSlot;
        end
    end

    if ~exist('maxIter','var')
        %sic returns the MAC frame (sicRAF) including only solved packets
        %it returns the resolved user (sicRow),and resolve frame (sicCol)
        [sicRAF,sicCol,sicRow] = sic(randomAccessFrame,twinsOverhead); % do the Successive Interference Cancellation
    elseif exist('maxIter','var')
        [sicRAF,sicCol,sicRow] = sic(randomAccessFrame,twinsOverhead,maxIter); % do the Successive Interference Cancellation
    end

    pcktTransmissionAttempts = pcktTransmissionAttempts + sum(sourceStatus == 1); % "the normalized MAC load G does not take into account the replicas" Casini et al., 2007, pag.1411; "The performance parameter is throughput (measured in useful packets received per slot) vs. load (measured in useful packets transmitted per slot" Casini et al., 2007, pag.1415
    ackdPacketCount = ackdPacketCount + numel(sicCol);

    sourcesReady = find(sourceStatus);
    sourcesCollided = setdiff(sourcesReady,sicRow);
    % if numel(sourcesCollided) > 0
    %     pcktCollisionCount = pcktCollisionCount + numel(sourcesCollided);
    %     sourceStatus(sourcesCollided) = 2;
    % end

    sourceStatus = sourceStatus - 1; % update sources statuses
    sourceStatus(sourceStatus < 0) = 0; % idle sources stay idle (see permitted statuses above)
end

loadNorm = pcktTransmissionAttempts / (simulationTime * randomAccessFrameLength);
throughputNorm = ackdPacketCount / (simulationTime * randomAccessFrameLength);
pcktCollisionProb = pcktCollisionCount / (simulationTime * randomAccessFrameLength);
if pcktTransmissionAttempts ~= 0
    packetLossRatio = 1 - ackdPacketCount / pcktTransmissionAttempts;
elseif pcktTransmissionAttempts == 0 && ackdPacketCount == 0
    packetLossRatio = 0;
end