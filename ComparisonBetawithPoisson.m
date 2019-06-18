clear
clc
close all

%CM: This is a sample script to compare the performance of IRSA with fixed 
%channel number throughout 10 second between Beta and Poisson distribution.
%The distributions have same loads.

%Channel number is fixed during this 10 second!!!!

%Beta Distribution parameters
NumberOfUser = 30000; %1000, 3000, 5000, 10000, 30000 
steps=0.02; %3gpp standars: TA=10s steps=[0.01, 0.02, 0.04, 0.08, 0.1];

TA=10;%10 seconds
numberStep = TA/steps;

%IRSA parameters
maxChannelNumber=20;
randomAccessFrameLength =[10 20 40 80 160];
maxRepetitionRate = 8;

Iter=4;

B_AveLoad=zeros(length(randomAccessFrameLength),maxChannelNumber,Iter);
B_AveThroughput=zeros(length(randomAccessFrameLength),maxChannelNumber,Iter);
B_AvePLR=zeros(length(randomAccessFrameLength),maxChannelNumber,Iter);
B_ActiveUser=zeros(length(randomAccessFrameLength),numberStep,Iter);

P_AveLoad=zeros(length(randomAccessFrameLength),maxChannelNumber,Iter);
P_AveThroughput=zeros(length(randomAccessFrameLength),maxChannelNumber,Iter);
P_AvePLR=zeros(length(randomAccessFrameLength),maxChannelNumber,Iter);
P_ActiveUser=zeros(length(randomAccessFrameLength),numberStep,Iter);


for it=1:Iter
    for i=1:length(randomAccessFrameLength)
        [B_AveLoad(i,:,it),B_AveThroughput(i,:,it),B_AvePLR(i,:,it), B_ActiveUser(i,:,it)] = irsa_beta(NumberOfUser,steps,maxChannelNumber, randomAccessFrameLength(i),maxRepetitionRate);
        [P_AveLoad(i,:,it),P_AveThroughput(i,:,it),P_AvePLR(i,:,it), P_ActiveUser(i,:,it)] = irsa_poisson(NumberOfUser,steps,maxChannelNumber, randomAccessFrameLength(i),maxRepetitionRate);
    end
end

B_AveLoad_Iter=mean(B_AveLoad,3);
B_AveThroughput_Iter=mean(B_AveThroughput,3);
B_AvePLR_Iter=zeros(length(randomAccessFrameLength),maxChannelNumber);
B_ActiveUser_Iter=sum(B_ActiveUser,2);
B_ActiveUser_Iter_Frame=sum(B_ActiveUser_Iter,3);

P_AveLoad_Iter=mean(P_AveLoad,3);
P_AveThroughput_Iter=mean(P_AveThroughput,3);
P_AvePLR_Iter=zeros(length(randomAccessFrameLength),maxChannelNumber);
P_ActiveUser_Iter=sum(P_ActiveUser,2);
P_ActiveUser_Iter_Frame=sum(P_ActiveUser_Iter,3);

for it=1:Iter
    for i=1:length(randomAccessFrameLength)
        step=B_ActiveUser_Iter(i,it);
        B_AvePLR_Iter(i,:)= B_AvePLR_Iter(i,:) + (B_AvePLR(i,:,it)*(step/B_ActiveUser_Iter_Frame(i)));
        step_P=P_ActiveUser_Iter(i,it);
        P_AvePLR_Iter(i,:)= P_AvePLR_Iter(i,:) + (P_AvePLR(i,:,it)*(step_P/P_ActiveUser_Iter_Frame(i)));
    end
end

save('sims_1_pois_vs_beta.mat')

% figure
% subplot(3,1,1);
% hold on
% plot(B_AveLoad_Iter(1,:),'r')
% plot(B_AveLoad_Iter(2,:),'b')
% plot(B_AveLoad_Iter(3,:),'g')
% plot(B_AveLoad_Iter(4,:),'k')
% plot(B_AveLoad_Iter(5,:),'y')
% plot(P_AveLoad_Iter(1,:),'--r')
% plot(P_AveLoad_Iter(2,:),'--b')
% plot(P_AveLoad_Iter(3,:),'--g')
% plot(P_AveLoad_Iter(4,:),'--k')
% plot(P_AveLoad_Iter(5,:),'--y')
% legend('10', '20', '40', '80', '160')
% title("Load");
% grid on
% 
% subplot(3,1,2);
% hold on
% plot(B_AveThroughput_Iter(1,:),'r')
% plot(B_AveThroughput_Iter(2,:),'b')
% plot(B_AveThroughput_Iter(3,:),'g')
% plot(B_AveThroughput_Iter(4,:),'k')
% plot(B_AveThroughput_Iter(5,:),'y')
% plot(P_AveThroughput_Iter(1,:),'--r')
% plot(P_AveThroughput_Iter(2,:),'--b')
% plot(P_AveThroughput_Iter(3,:),'--g')
% plot(P_AveThroughput_Iter(4,:),'--k')
% plot(P_AveThroughput_Iter(5,:),'--y')
% title("Throughput");
% grid on
% 
% subplot(3,1,3);
% hold on
% plot(B_AvePLR_Iter(1,:),'r')
% plot(B_AvePLR_Iter(2,:),'b')
% plot(B_AvePLR_Iter(3,:),'g')
% plot(B_AvePLR_Iter(4,:),'k')
% plot(B_AvePLR_Iter(5,:),'y')
% plot(log10((B_AvePLR(1,:))),'r')
% plot(log10((B_AvePLR(2,:))),'b')
% plot(log10((B_AvePLR(3,:))),'g')
% plot(P_AvePLR_Iter(1,:),'--r')
% plot(P_AvePLR_Iter(2,:),'--b')
% plot(P_AvePLR_Iter(3,:),'--g')
% plot(P_AvePLR_Iter(4,:),'--k')
% plot(P_AvePLR_Iter(5,:),'--y')
% plot(log10((PAvePLR(1,:))),'--r')
% plot(log10((PAvePLR(2,:))),'--b')
% plot(log10((PAvePLR(3,:))),'--g')
% title("PLR");
% grid on