function [NumberOfChannel] = optimize_numberOfChannel(NumberOfUser,maxChannelNumber, randomAccessFrameLength,packetReadyProb,maxRepetitionRate)
%This function gives the optimum number of channel with given number of
%Active Users, randomAccessFrameLength, and degree distribution under the
%constraints of maxChannelNumber and Packet Loss Rate of 0.1.

% +++ Inputs
%     - NumberOfUser: Number of users
%     - maxChannelNumber: maximum usable number of channels
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
% 
% +++ Outputs
%     - NumberOfChannel: optimum number of channel which maximizes the
%     normalized throughout under the constraint of Packet Loss Rate of 0.1



Load=zeros(1,maxChannelNumber);
Throughput=zeros(1,maxChannelNumber);
PLR=zeros(1,maxChannelNumber);
maxPLR=0.1; %Packet Loss Rate constraint

for c=1:maxChannelNumber
   ExpectedUseronchannel = round(NumberOfUser/c); %Assume each channel has equal number of users like expectation
   if(ExpectedUseronchannel < 3)
       Load(c)=0;
       Throughput(c)=0;
       PLR(c)=0;
   else
       %It's better to make 50 consequent RAFs instead of just 1 RAF while
       %calling the IRSA simulator, because one of extreme scenarios can
       %happen in 1 RAF and our optimization can fail in the real scenario.
       %But we can avoid these extreme cases by taking average of 50 
       %consequent RAFs.
       [Load(c),Throughput(c),PLR(c)] = irsa(ExpectedUseronchannel,randomAccessFrameLength,packetReadyProb,maxRepetitionRate,50);
   end
end
[~,NumberOfChannel]=max(Throughput);

%In real scenarios, we have packet loss rate constraint. Therefore, we
%should conside this constraint before finding the optimum channel number.
while(PLR(NumberOfChannel)>maxPLR)
    NumberOfChannel=NumberOfChannel+1;
    if( NumberOfChannel > maxChannelNumber)
        NumberOfChannel = maxChannelNumber;
        break
    end
end
end

