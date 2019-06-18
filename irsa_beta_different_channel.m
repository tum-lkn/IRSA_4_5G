function [AveLoad,AveThroughput,AvePLR] = irsa_beta_different_channel(NumberOfUser,steps,maxChannelNumber, randomAccessFrameLength,maxRepetitionRate)
%In this function, we simulate multiple channel IRSA during the period of 
%one Random Access Frame (RAF). We first created the beta distribution
%based on the reference [21] in the conference paper, then we discretize this
%distribution based on the given step size (steps).
%Then we calculate expected number of users in each discrete time-step,
%we find the optimum number of channels with this expected number of users
%by using the function "optimize_numberOfChannel.m" again in each this
%time-step. After finding the optimum channel number, each user dices if
%they are active or not in this specific time-step. Thereafter, we're
%calling the "multichannelIRSA.m" function to find the performance metrics
%in this specific time-step. 
%After finding all performence metrics of all time-steps, we're averaging
%them to find the performence metrics of whole frame.


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


%Beta dist parameters taken reference [21] in the conference paper
alpha=3;
B=4;
TA=10;%10 seconds
numberStep = TA/steps;

%IRSA parameters
simulationTime = 1;
packetReadyProb = 1;


Load=zeros(numberStep,1); 
Throughput=zeros(numberStep,1);
PLR=zeros(numberStep,1);
ActiveUser=zeros(numberStep,1); %active user at each time step
NumberOfChannel=zeros(numberStep,1); %expected active user at each time step

%Beta dist p(t) 
p =@(t) ((t.^(alpha-1)) .* ((TA -t).^(B-1))) /((TA^(alpha+B-1))*beta(alpha,B));

n=1;
Pts=zeros((TA/steps),1);

for t=0:steps:(TA-steps)
    %to find the number of active users in each discrete time-steps.
    Pts(n) = integral(p,t,t+steps);
    ExpectedUser=NumberOfUser*Pts;
    %optimization
    NumberOfChannel(n)=optimize_numberOfChannel(ExpectedUser(n),maxChannelNumber, randomAccessFrameLength,packetReadyProb,maxRepetitionRate);

    Active=zeros(NumberOfUser,1);
    %Check every users if they are active or not
    for i=1:NumberOfUser
        %assign 1 if the user is active
        if rand(1) <= Pts(n)
            Active(i) = 1;
        end
    end
    NumberOfActiveUsers = sum(Active(:,1) == 1);
    ActiveUser(n) = NumberOfActiveUsers;
   [Load(n,1),Throughput(n,1),PLR(n,1)]=multichannelIRSA(NumberOfActiveUsers,NumberOfChannel(n),randomAccessFrameLength,packetReadyProb,maxRepetitionRate,simulationTime);
    n=n+1;
end

TotalChannel=sum(NumberOfChannel(:));
AveLoad=0;
AveThroughput=0;
AvePLR=0;

for z=1:numberStep
    %For the normalized load and normalized throughput, we're doing a moving
    %average, because the resources are same for all discrete time-steps.
    %But to calculate the average packet loss rate, we should take weighted
    %average of all PLRs in discrete time-steps, because theses discrete time-steps
    %are possible to have different number of active users.
    AveLoad = AveLoad + ((NumberOfChannel(z)/TotalChannel)*Load(z,1));
    AveThroughput = AveThroughput + ((NumberOfChannel(z)/TotalChannel)*Throughput(z,1));
    AvePLR = AvePLR + PLR(z,1) * (ActiveUser(z,1) / sum(ActiveUser(:)));
end
    %ActiveUser=transpose(ActiveUser);
end

