%CM: A sample script to run the function "Direct_Beta.m", which calculate
%the performance of IRSA with an exact Beta distribution.

%Beta dist parameters taken reference [21] in the conference paper
NumberOfUser = 30000; %[1000, 3000, 5000, 10000, 30000]; 
steps= [0.04 0.1 0.2 0.25 0.4 0.5];%[0.01, 0.02, 0.04, 0.08, 0.1]; %3gp standars: TA=10s

%IRSA parameters
maxChannelNumber= 120;
randomAccessFrameLength = [80 160 320 480];%[10 20 40 80 160];
maxRepetitionRate = 8;

Iter=1;

AveLoad=zeros(length(randomAccessFrameLength),length(steps),Iter);
AveThroughput=zeros(length(randomAccessFrameLength),length(steps),Iter);
AvePLR=zeros(length(randomAccessFrameLength),length(steps),Iter);
%PLR=zeros(numberStep,maxChannelNumber,length(randomAccessFrameLength));
%ActiveUser=zeros(numberStep,length(steps),length(randomAccessFrameLength));
%NumberOfChannel=zeros(numberStep,length(steps),length(randomAccessFrameLength));

tic
for it=1:Iter
    for t=1:length(randomAccessFrameLength)
        for i=1:length(steps)
           [AveLoad(t,i,it),AveThroughput(t,i,it),AvePLR(t,i,it)] = Direct_Beta(NumberOfUser,steps(i),maxChannelNumber, randomAccessFrameLength(t),maxRepetitionRate);
        end
    end
end
toc


AveLoad_1 = mean(AveLoad,3); 
AveThroughput_1 = mean(AveThroughput,3); 
AvePLR_1 = mean(AvePLR,3); 

figure
subplot(3,1,1);
hold on
plot(steps,AveLoad_1(1,:),'r')
plot(steps,AveLoad_1(2,:),'b')
plot(steps,AveLoad_1(3,:),'g')
plot(steps,AveLoad_1(4,:),'--r')
%plot(steps,AveLoad_1(5,:),'--b')
%legend('10','20','40','80', '160')
legend('80', '160', '320', '480')
title("Load");
grid on

subplot(3,1,2);
hold on
plot(steps,AveThroughput_1(1,:),'r')
plot(steps,AveThroughput_1(2,:),'b')
plot(steps,AveThroughput_1(3,:),'g')
plot(steps,AveThroughput_1(4,:),'--r')
%plot(steps,AveThroughput_1(5,:),'--b')
title("Throughput");
grid on

subplot(3,1,3);
hold on
plot(steps,((AvePLR_1(1,:))),'r')
plot(steps,((AvePLR_1(2,:))),'b')
plot(steps,((AvePLR_1(3,:))),'g')
plot(steps,((AvePLR_1(4,:))),'--r')
%plot(steps,((AvePLR_1(5,:))),'--b')
title("PLR");
grid on