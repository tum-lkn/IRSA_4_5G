% A script to run the function "irsa_beta_different_channel.m" with
% different discrete stepsize and different subcarrier spacing. In 5G,
% allowed subcarrier spacing is limeted with 15, 30, 60, 120, 240 kHZ.
%In the paper, we defined latency = waiting time + 2*frame length
%We assumed the waiting time is constant and equal to zero for all
%subcarrier spacings to have a good comprasion. Then, we find the random
%access frame length based on different subcarrier spacings under the
%constaint that all systems use same amount of resources. 

NumberOfUser = 30000; 
steps=[0.2 0.25 0.4];%[0.01, 0.02, 0.04, 0.08, 0.1]; 

maxChannelNumber= 120;
ScS = [15 30 60 240]; %Sub carrier spacing
maxRepetitionRate = 8;

Iter=4;

AveLoad=zeros(length(ScS),length(steps),Iter);
AveThroughput=zeros(length(ScS),length(steps),Iter);
AvePLR=zeros(length(ScS),length(steps),Iter);

tic
for it=1:Iter
    for t=1:length(ScS)
        for i=1:length(steps)
            randomAccessFrameLength = steps(i) * (ScS(t)/15) *1000
            [AveLoad(t,i,it),AveThroughput(t,i,it),AvePLR(t,i,it)] = irsa_beta_different_channel(NumberOfUser,steps(i),maxChannelNumber, randomAccessFrameLength,maxRepetitionRate);
        end
    end
end
toc

%NOT: Load replikalarý dikkate almýyor!!!

AveLoad_1 = mean(AveLoad,3); 
AveThroughput_1 = mean(AveThroughput,3); 
AvePLR_1 = mean(AvePLR,3); 

figure
subplot(3,1,1);
hold on
plot(steps,AveLoad_1(1,:),'r')
plot(steps,AveLoad_1(2,:),'b')
plot(steps,AveLoad_1(3,:),'g')
plot(steps,AveLoad_1(4,:),'k')
legend('15 kHZ','30 kHZ','60 kHZ','240 kHZ')
xlabel("Step size in second")
title("Load");
grid on

subplot(3,1,2);
hold on
plot(steps,AveThroughput_1(1,:),'r')
plot(steps,AveThroughput_1(2,:),'b')
plot(steps,AveThroughput_1(3,:),'g')
plot(steps,AveThroughput_1(4,:),'k')
xlabel("Step size in second")
title("Throughput");
grid on

subplot(3,1,3);
hold on
plot(steps,((AvePLR_1(1,:))),'r')
plot(steps,((AvePLR_1(2,:))),'b')
plot(steps,((AvePLR_1(3,:))),'g')
plot(steps,((AvePLR_1(4,:))),'k')
xlabel("Step size in second")
title("PLR");
grid on