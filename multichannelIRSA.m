function [SumloadNorm,SumthroughputNorm,SumpacketLossRatio] = multichannelIRSA(sourceNumber,ChannelNumber,randomAccessFrameLength,packetReadyProb,maxRepetitionRate,simulationTime,maxIter)
% In this function, each user randomly selects a channel, he uses, out of
% ChannelNumber usable channels. Then number of users in each channel is
% found and all performance metrics in each channel are calculated. Then
% we find average values of these performance metrics for whole system.

% +++ Inputs
%     - sourceNumber: Number of users
%     - ChannelNumber: Number of usable channels
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
%     - SumloadNorm: Normalized Load
%     - SumthroughputNorm: Normalized Throughput
%     - SumpacketLossRatio: Packet Loss Rate

selectedChannels=zeros(1,sourceNumber);

for i=1:sourceNumber
   %Each user selects a random channel
   selectedChannels(1,i)=randi(ChannelNumber);
end
SumloadNorm=0;
SumthroughputNorm=0;
SumpacketLossRatio=0;
n=0;
numberOfuserIneachChanel=zeros(1,ChannelNumber);

%find number of users in each channel and average values
for t=1:ChannelNumber
   numberOfuserIneachChanel(1,t)=sum(selectedChannels(1,:) == t);
   if(sourceNumber == 0)
        SumloadNorm=0;
        SumthroughputNorm=0;
        SumpacketLossRatio=0;
        break
   elseif(numberOfuserIneachChanel(1,t)<3)
       loadNorm=0;
       throughputNorm=0;
       packetLossRatio=0;
       %warning('Less than 3 users in one channel')
   elseif ~exist('maxIter','var')
        [loadNorm,throughputNorm,packetLossRatio] = irsa(numberOfuserIneachChanel(1,t),randomAccessFrameLength,packetReadyProb,maxRepetitionRate,simulationTime);
   elseif exist('maxIter','var')
        [loadNorm,throughputNorm,packetLossRatio] = irsa(numberOfuserIneachChanel(1,t),randomAccessFrameLength,packetReadyProb,maxRepetitionRate,simulationTime,maxIter);
   end
   
   %For the normalized load and normalized throughput, we're doing a moving
   %average, because the resources (slot numbers) are same for all
   %channels.
   %But to calculate the average packet loss rate, we should take weighted
   %average of all PLRs in all channels, because the channels are possible
   %to have different number of active users.
   SumloadNorm = (loadNorm +(n*SumloadNorm))/(n+1);
   SumthroughputNorm = (throughputNorm +(n*SumthroughputNorm))/(n+1);
   SumpacketLossRatio = (packetLossRatio*(numberOfuserIneachChanel(1,t)/sourceNumber)) + SumpacketLossRatio;
   n=n+1;   
end

%fprintf('\nNetwork load (G): %.3f,\nNetwork throughput (S): %.3f,\nPacket loss ratio: %.4f.\n',SumloadNorm,SumthroughputNorm,SumpacketLossRatio);
end

