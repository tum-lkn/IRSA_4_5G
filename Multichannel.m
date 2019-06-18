clear all;
clc;
%CM: A sample script to run the function "multichannelIRSA.m", which gives
%the change of the performance metrics by increasing number of channel

sourceNumber=600;
channel=1:20;
randomAccessFrameLength = 50; 
simulationTime = 1;
packetReadyProb = 1;
maxRepetitionRate = 8;
maxSicIterations = 150;

Load=zeros(1,length(channel));
Throughput=zeros(1,length(channel));
PLR=zeros(1,length(channel));

for i=1:length(channel)
    [Load(1,i),Throughput(1,i),PLR(1,i)]=multichannelIRSA(sourceNumber,i,randomAccessFrameLength,packetReadyProb,maxRepetitionRate,simulationTime);
end

figure
subplot(3,1,1);
plot(Load);
title("Load");
grid on

subplot(3,1,2);
plot(Throughput);
title("Throughput");
grid on

subplot(3,1,3);
plot(PLR);
title("PLR");
grid on