% CM: A sample script to run the simulation function "irsa.m"

clear all;

sourceNumber = 40;
randomAccessFrameLength = 50; % Liva, 2011, pag. 482
simulationTime = 1e2; % total number of RAF
packetReadyProb = .75;
maxRepetitionRate = 3;
maxSicIterations = 150;

[loadNorm,throughputNorm,packetLossRatio] = irsa(sourceNumber,randomAccessFrameLength,packetReadyProb,maxRepetitionRate,simulationTime);

fprintf('\nNetwork load (G): %.3f,\nNetwork throughput (S): %.3f,\nPacket loss ratio: %.4f.\n',loadNorm,throughputNorm,packetLossRatio);
