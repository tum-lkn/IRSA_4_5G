clear
clc
close all

%CM: This is a sample script to calculate the performance of IRSA with the
%Beta distribution with the help of function "irsa_beta.m", which uses the
%fixed number of channel throughout the whole simulation time.

%Channel number is fixed during this 10 second!!!!

%Beta dist parameters taken reference [21] in the conference paper
NumberOfUser = 30000; %1000, 3000, 5000, 10000, 30000 
steps=0.01; %3gpp standars: TA=10s steps=[0.01, 0.02, 0.04, 0.08, 0.1];
TA=10;%10 seconds.
numberStep = TA/steps;

%IRSA parameters
maxChannelNumber=20;
randomAccessFrameLength =[10 20 40 80 160];%randomAccessFrameLength = [10 20 40 80 160];
maxRepetitionRate = 8;

Iter=4;

AveLoad=zeros(length(randomAccessFrameLength),maxChannelNumber, Iter);
AveThroughput=zeros(length(randomAccessFrameLength),maxChannelNumber, Iter);
AvePLR=zeros(length(randomAccessFrameLength),maxChannelNumber, Iter);
%PLR=zeros(numberStep,maxChannelNumber,length(randomAccessFrameLength));
ActiveUser=zeros(numberStep,length(randomAccessFrameLength, Iter));

for it=1:Iter
    for i=1:length(randomAccessFrameLength)
        %[AveLoad(i,:),AveThroughput(i,:),AvePLR(i,:)] = irsa_beta(NumberOfUser,steps,maxChannelNumber, randomAccessFrameLength(i),maxRepetitionRate);
        [AveLoad(i,:),AveThroughput(i,:),AvePLR(i,:), ActiveUser(:,i)] = irsa_beta(NumberOfUser,steps,maxChannelNumber, randomAccessFrameLength(i),maxRepetitionRate);
    end
end


figure
subplot(3,1,1);
hold on
plot(AveLoad(1,:),'r')
plot(AveLoad(2,:),'b')
plot(AveLoad(3,:),'g')
plot(AveLoad(4,:),'--r')
plot(AveLoad(5,:),'--b')
legend('10','20', '40', '80', '160')
title("Load");
grid on

subplot(3,1,2);
hold on
plot(AveThroughput(1,:),'r')
plot(AveThroughput(2,:),'b')
plot(AveThroughput(3,:),'g')
plot(AveThroughput(4,:),'--r')
plot(AveThroughput(5,:),'--b')
title("Throughput");
grid on

subplot(3,1,3);
hold on
plot(log10((AvePLR(1,:))),'r')
plot(log10((AvePLR(2,:))),'b')
plot(log10((AvePLR(3,:))),'g')
plot(log10((AvePLR(4,:))),'--r')
plot(log10((AvePLR(5,:))),'--b')
title("PLR");
grid on
