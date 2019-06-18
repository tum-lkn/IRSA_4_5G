function [outRandomAccessFrame,ackedPcktsCol,ackedPcktsRow] = sic(randomAccessFrame,twinsOverhead,maxIter)
% perform Successive Interference Cancellation (SIC) on a given Random Access Frame for Contention Resolution Diversity Slotted Aloha
%
% [output RAF, acked packets column indices,acked packets row indices] = sic(Random Access Frame,twins overhead,max SIC iterations)
%
% +++ Input parameters
% 		- Random Access Frame: the logical matrix containing slots and packets informations
% 		- twins overhead: an array containing the column indices of packets that did not encounter collision (can include acked twins)
% 		- max SIC iterations: an array containing the row indices of packets that did not encounter collision (can include acked twins)
%
% +++ Output parameters
% 		- output RAF: the RAF matrix containing slots and packets informations, after SIC
% 		- acked packets column indices: an array containing the column indices of acknowledged packets after SIC
% 		- acked packets row indices: an array containing the row indices of acknowledged packets after SIC

narginchk(2,3);
validateattributes(randomAccessFrame,{'numeric'},{'integer','nonnegative'},mfilename,'Random Access Frame',1)
validateattributes(twinsOverhead,{'cell'},{'nonempty','numel', numel(randomAccessFrame)},mfilename,'Twins overhead',2)
if exist('maxIter','var') % complete SIC
    validateattributes(maxIter,{'numeric'},{'integer','positive'},mfilename,'maximum SIC iterations',3)
end

nonCollPcktsCol=find(sum(randomAccessFrame>0)==1); % find slot indices of packets without collisions
if numel(nonCollPcktsCol) == 0
    outRandomAccessFrame = randomAccessFrame;
    ackedPcktsCol = [];
    ackedPcktsRow = [];
elseif numel(nonCollPcktsCol) > 0
    %to find used slots
    [row_c,col_c] = find(randomAccessFrame);
    row=transpose(row_c);
    col=transpose(col_c);
    [~,col_ind]=ismember(nonCollPcktsCol,col);
    nonCollPcktsRow = row(col_ind); % find source indices of packets without collisions
    nonCollPacketIdx = 1;

    if ~exist('maxIter','var') % complete SIC
        while nonCollPacketIdx <= numel(nonCollPcktsCol) %for each noncollided packet
            twinPcktCol = twinsOverhead{ nonCollPcktsRow(nonCollPacketIdx),nonCollPcktsCol(nonCollPacketIdx) };%find other slots
            for twinPcktIdx = 1:length(twinPcktCol)
                if sum(randomAccessFrame(:,twinPcktCol(twinPcktIdx))) > 1 % twin packet has collided
                    randomAccessFrame(nonCollPcktsRow(nonCollPacketIdx),twinPcktCol(twinPcktIdx)) = 0; % cancel interference %random access frame'de denk gelen yere sýfýr yazar
                    if sum(randomAccessFrame(:,twinPcktCol(twinPcktIdx))) == 1; % check if a new package can be acknowledged, thanks to interference cancellation %eðer o slotta kalan kullanýcý sayýsý bir olursa, bu da çözüldü
                        nonCollPcktsCol = [nonCollPcktsCol,twinPcktCol(twinPcktIdx)]; % update non collided packets indices arrays % TODO: The variable 'nonCollPcktsCol' appears to change size on every loop iteration. Consider preallocating for speed. [Issue: https://github.com/afcuttin/irsa/issues/12]
                        nonCollPcktsRow = [nonCollPcktsRow,find(randomAccessFrame(:,twinPcktCol(twinPcktIdx)))]; % TODO: The variable 'nonCollPcktsRow' appears to change size on every loop iteration. Consider preallocating for speed. [Issue: https://github.com/afcuttin/irsa/issues/10]
                    end
                elseif sum(randomAccessFrame(:,twinPcktCol(twinPcktIdx))>0) == 1 % twin packet has not collided
                    randomAccessFrame(nonCollPcktsRow(nonCollPacketIdx),twinPcktCol(twinPcktIdx)) = 0; % cancel interference
                    nonCollTwinInd = find(nonCollPcktsCol == twinPcktCol(twinPcktIdx));
                    nonCollPcktsCol(nonCollTwinInd) = []; %remove the twin packet from the acked packets list
                    nonCollPcktsRow(nonCollTwinInd) = [];
                end
            end
            nonCollPacketIdx = nonCollPacketIdx + 1;
        end

        outRandomAccessFrame = randomAccessFrame;
        ackedPcktsCol = nonCollPcktsCol;
        ackedPcktsRow = nonCollPcktsRow;

    elseif exist('maxIter','var') % iteration limted SIC
        while nonCollPacketIdx <= maxIter && nonCollPacketIdx <= numel(nonCollPcktsCol)
            twinPcktCol = twinsOverhead{ nonCollPcktsRow(nonCollPacketIdx),nonCollPcktsCol(nonCollPacketIdx) };
            for twinPcktIdx = 1:length(twinPcktCol)
                if sum(randomAccessFrame(:,twinPcktCol(twinPcktIdx))) > 1 % twin packet has collided
                    randomAccessFrame(nonCollPcktsRow(nonCollPacketIdx),twinPcktCol(twinPcktIdx)) = 0; % cancel interference
                    if sum(randomAccessFrame(:,twinPcktCol(twinPcktIdx))) == 1; % check if a new package can be acknowledged, thanks to interference cancellation
                        nonCollPcktsCol = [nonCollPcktsCol,twinPcktCol(twinPcktIdx)]; % update non collided packets indices arrays
                        nonCollPcktsRow = [nonCollPcktsRow,find(randomAccessFrame(:,twinPcktCol(twinPcktIdx)))];
                    end
                elseif sum(randomAccessFrame(:,twinPcktCol(twinPcktIdx))>0) == 1 % twin packet has not collided
                    randomAccessFrame(nonCollPcktsRow(nonCollPacketIdx),twinPcktCol(twinPcktIdx)) = 0; % cancel interference
                    nonCollTwinInd = find(nonCollPcktsCol == twinPcktCol(twinPcktIdx));
                    nonCollPcktsCol(nonCollTwinInd) = []; %remove the twin packet from the acked packets list
                    nonCollPcktsRow(nonCollTwinInd) = [];
                end
            end
            nonCollPacketIdx = nonCollPacketIdx + 1;
        end

        while nonCollPacketIdx <= numel(nonCollPcktsCol) % check if the remaining non collided packets are replicas, and delete them
            twinPcktCol = twinsOverhead{ nonCollPcktsRow(nonCollPacketIdx),nonCollPcktsCol(nonCollPacketIdx) };
            for twinPcktIdx = 1:length(twinPcktCol)
                randomAccessFrame(nonCollPcktsRow(nonCollPacketIdx),twinPcktCol(twinPcktIdx)) = 0; % cancel interference
                nonCollTwinInd = find(nonCollPcktsCol == twinPcktCol(twinPcktIdx));
                nonCollPcktsCol(nonCollTwinInd) = []; %remove the twin packet from the acked packets list
                nonCollPcktsRow(nonCollTwinInd) = [];
            end
            nonCollPacketIdx = nonCollPacketIdx + 1;
        end

        outRandomAccessFrame = randomAccessFrame;
        ackedPcktsCol = nonCollPcktsCol;
        ackedPcktsRow = nonCollPcktsRow;
    end
end