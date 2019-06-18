function [pcktTwins,rafRow] = generateTwins(randomAccessFrameLength,numberOfTwins)
% [packet twins,RAF row] = generateTwins(RAF length,number of twins)
%
% Given the length of the Random Access Frame (RAF) and the number of packet replicas to be
% transmitted within the RAF, the function returns an array of the slots index where the replicas
% will be transmitted, and a cell array containing -for every replica- the pointers to the other twins.

validateattributes(randomAccessFrameLength,{'numeric'},{'integer','positive'},mfilename,'RAF length',1)
validateattributes(numberOfTwins,{'numeric'},{'integer','positive','<', randomAccessFrameLength},mfilename,'number of twins',2)

rafRow = cell(1,randomAccessFrameLength);
pcktTwins = randperm(randomAccessFrameLength,numberOfTwins);
for i = 1:length(pcktTwins)
	twinsPointers = pcktTwins;
	twinsPointers(i) = [];
	rafRow{pcktTwins(i)} = twinsPointers;
end