%A script to run the function "irsa_beta_different_channel.m" with
%different Random Access Frame Lengths and different discrete time-step 
%lengths. Remember: irsa_beta_different_channel.m function uses optimum
%channel number in each discrete time-step.


%Beta Distribution parameters
NumberOfUser = 30000; %[1000, 3000, 5000, 10000, 30000]; %3gpp standards
steps=[0.01, 0.02, 0.04, 0.08, 0.1]; %[0.04 0.1 0.2 0.25 0.4 0.5]; % %3gp standars: TA=10s

%IRSA parameters
maxChannelNumber= 120;
randomAccessFrameLength = [10 20 40 80 160];%[80 160 320 480]; %[10 20 40 80 160];
maxRepetitionRate = 2.3;

Iter=4;

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
            %[AveLoad(t,i,1),AveThroughput(t,i,1),AvePLR(t,i,1), ActiveUser(:,t,i),NumberOfChannel(:,t,i)] = irsa_beta_different_channel(NumberOfUser(t),steps,maxChannelNumber, randomAccessFrameLength(i),maxRepetitionRate);
            [AveLoad(t,i,it),AveThroughput(t,i,it),AvePLR(t,i,it)] = irsa_beta_different_channel(NumberOfUser,steps(i),maxChannelNumber, randomAccessFrameLength(t),maxRepetitionRate);
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
plot(steps,AveLoad_1(5,:),'--b')
legend('10','20','40','80', '160')
xlabel("Step size in second")
title("Load");
grid on

subplot(3,1,2);
hold on
plot(steps,AveThroughput_1(1,:),'r')
plot(steps,AveThroughput_1(2,:),'b')
plot(steps,AveThroughput_1(3,:),'g')
plot(steps,AveThroughput_1(4,:),'--r')
plot(steps,AveThroughput_1(5,:),'--b')
xlabel("Step size in second")
title("Throughput");
grid on

subplot(3,1,3);
hold on
plot(steps,((AvePLR_1(1,:))),'r')
plot(steps,((AvePLR_1(2,:))),'b')
plot(steps,((AvePLR_1(3,:))),'g')
plot(steps,((AvePLR_1(4,:))),'--r')
plot(steps,((AvePLR_1(5,:))),'--b')
xlabel("Step size in second")
title("PLR");
grid on