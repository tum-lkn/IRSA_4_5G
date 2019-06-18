function [AveLoad,AveThroughput,AvePLR, ActiveUser] = irsa_beta(NumberOfUser,steps,maxChannelNumber, randomAccessFrameLength,maxRepetitionRate )
%In this function, we simulate multiple channel IRSA during the period of 
%one Random Access Frame (RAF). We first created the beta distribution
%based on the reference [21] in the conference paper, then we discretize this
%distribution based on the given step size (steps).
%For each channel number from 1 to maxChannelNumber and given parameters, this 
%function calculates the average Load, TP, and PLR vectors. So, there is no
%optimization in this case, and FIXED channel number is used throughout the
%simulation time (in all time-steps).

%Channel number is fixed during this 10 second!!!!

% +++ Inputs
%     - NumberOfUser: Number of users
%     - steps: length of a discrete time-step in second
%     - maxChannelNumber: maximum usable number of channels
%     - randomAccessFrameLength: How many slots has one IRSA frame?
%     - maxRepetitionRate: defines the degree distribution 
%             - 2.3: 0.7x^2 + 0.3x^3 defined by MG, CM
%             - 3: x^3 defined by MG, CM
%             - 4: 0.5102x^2 + 0.4898x^4 from G. Liva
%             - 5: 0.5631x^2 + 0.0436x^3 + 0.3933x^5 from G. Liva
%             - 6: 0.5465x^2 + 0.1623x^3 + 0.2912x^6 from G. Liva
%             - 8: 0.5x^2 + 0.28x^3 + 0.22x^8 from G. Liva
%             - otherwise: 0.4977x^2 + 0.2207x^3 + 0.0381x^4 + 0.0756x^5 + 0.0398x^6 ...
%                 + 0.0009x^7 + 0.0088x^8 + 0.0068x^9 + 0.0030x^11 + 0.0429x^14 + 0.0081x^15 + 0.0576x^16 from G. Liva
% 
% +++ Outputs
%     - AveLoad: The average normalized Load found by the simulator during
%     the period of one RAF
%     - AveThroughput: The average normalized Throughput found by the simulator during
%     the period of one RAF
%     - AvePLR: The average Packet Loss Rate found by the simulator during
%     the period of one RAF
%     - ActiveUser: Number of active users in each discrete time-step

%Beta dist parameters taken reference [21] in the conference paper
alpha=3;
B=4;
TA=10;%10 seconds
numberStep = TA/steps;

%IRSA parameters
channel=1:maxChannelNumber;
simulationTime = 1;
packetReadyProb = 1;

%Load, Throughput, PLR are matrices show values at a time step with a given
%number of channel
Load=zeros(numberStep,length(channel)); 
Throughput=zeros(numberStep,length(channel));
PLR=zeros(numberStep,length(channel));
ActiveUser=zeros(numberStep,1); %active user at each time step
AveLoad=zeros(1,length(channel));
AveThroughput=zeros(1,length(channel));
AvePLR=zeros(1,length(channel));

%Beta dist p(t) 
p =@(t) ((t.^(alpha-1)) .* ((TA -t).^(B-1))) /((TA^(alpha+B-1))*beta(alpha,B));

n=1;
Pts=zeros(1,(TA/steps));
for t=0:steps:(TA-steps)
    %to find the number of active users in each discrete time-steps.
    Pts(n) = integral(p,t,t+steps);
    Active=zeros(NumberOfUser,1);
    for i=1:NumberOfUser
        %assign 1 if the user is active
        if rand(1) <= Pts(n)
            Active(i) = 1;
        end
    end
    NumberOfActiveUsers = sum(Active(:,1) == 1);
    ActiveUser(n) = NumberOfActiveUsers;
    for i=1:length(channel)
        %calculate Load, Throughput, and PLR for different numbers of
        %channel
        [Load(n,i),Throughput(n,i),PLR(n,i)]=multichannelIRSA(NumberOfActiveUsers,i,randomAccessFrameLength,packetReadyProb,maxRepetitionRate,simulationTime);
        %taking moving averages of Load ve TP
        %Load(x,y): x represents time step while y represents number of channel
        AveLoad(1,i) = (Load(n,i) +(n*AveLoad(1,i)))/(n+1);
        AveThroughput(1,i) = (Throughput(n,i) +(n*AveThroughput(1,i)))/(n+1);
    end
    n=n+1;
end    

%to calculate weighted average PLR 
for z=1:size(PLR,1)
    AvePLR(1,:) = AvePLR(1,:) + PLR(z,:) * (ActiveUser(z,1) / sum(ActiveUser(:)));
end

    ActiveUser=transpose(ActiveUser);
end

