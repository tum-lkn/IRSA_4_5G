Multi-Channel Adaptation of IRSA

IRSA algorithm is taken from https://github.com/afcuttin/irsa, which includes 
the files: LICENSE, generateTwins.m, irsa.m, sampleIrsaScript.m and sic.m.

Functions:

- irsa.m calculates the normalized load,the normalized throughput and Packet Loss 
Rate by using single channel, with a given parameters  "sourceNumber, randomAccessFrameLength, packetReadyProb, maxRepetitionRate, simulationTime, maxIter".
Note: We updated this function by adding two more degree distribution.

- GenerateTwins.m return the MAC frame includes twins.

- sic.m makes successive interference cancelation, and returns MAC frame with unsolved packets, solved users, and solved packets information.

Scripts:

- sampleIrsaScript.m is a sample script for IRSA.



------------------------------------------------------------------------------
The following flow chart introduces introduction of each function.

![Function Flow Chart](https://github.com/tum-lkn/IRSA_4_5G/blob/master/FlowChart.jpg)


Functions:

- multichannelIRSA.c: In this function, each user randomly selects a channel, he uses, out of ChannelNumber usable channels. Then number of users in each channel i% found and all performance metrics in each channel are calculated. Then we find average values of these performance metrics for whole system.

- irsa_beta.m: This function uses multichannelIRSA.c to simulate multiple channel IRSA during the period of one Random Access Frame (RAF). We first created the beta distribution based on the reference [21] in the conference paper, then we discretize this  distribution based on the given step size (steps). For each channel number from 1 to maxChannelNumber and given parameters, this function calculates the average normalized Load, normalized Throughput, and PLR vectors. So, there is no optimization in this case, and FIXED channel number is used throughout the simulation time (in all time-steps). NOTE: Channel number is fixed during this 10 second!!!!

- irsa_poisson.m: This function uses multichannelIRSA.c to simulate multiple channel IRSA during the period of one Random Access Frame (RAF). We first find the number of active users in each discrete time-step based on the poisson distribution. For each channel number from 1 to maxChannelNumber and given parameters, this function calculates the average Load, TP, and PLR vectors. So, there is no optimization in this case, and FIXED channel number is used throughout the frame length (in all time-steps). NOTE: Channel number is fixed during this 10 second!!!!

- optimize_numberOfChannel.m: This function gives the optimum number of channel with given number of Active Users, randomAccessFrameLength, and degree distribution under the constraints of maxChannelNumber and Packet Loss Rate of 0.1.

- optimize_numberOfChannel_2.m: This function is almost same with the function "optimize_numberOfChannel.m", which gives the optimum number of channel with given number of Active Users, randomAccessFrameLength, and degree distribution under the constraints of maxChannelNumber and Packet Loss Rate of 0.1. This function gives the normalized Load, normalized Throughput and Packet Loss Rate as additional outputs when the optimum channel number is used. This function is written to take some insights about dynamics.

- irsa_beta_different_channel.m: In this function, we simulate multiple channel IRSA during the period of one Random Access Frame (RAF). We first created the beta distribution based on the reference [21] in the conference paper, then we discretize this distribution based on the given step size (steps). Then we calculate expected number of users in each discrete time-step, we find the optimum number of channels with this expected number of users by using the function "optimize_numberOfChannel.m" again in each this time-step. After finding the optimum channel number, each user dices if they are active or not in this specific time-step. Thereafter, we're calling the "multichannelIRSA.m" function to find the performance metrics %in this specific time-step. After finding all performence metrics of all time-steps, we're averaging them to find the performence metrics of whole frame. NOTE: Channel number is varying from time-step to time-step!!!!

- Direct_Beta.m: In this function, we simulate the IRSA with exact Beta distribution. We discretize the distribution, and then take the expected value in each time step to find the active user in this time step. This function gives the performance metrics.

Scripts:

- Multichannel.m: A sample script to run the function "multichannelIRSA.m", which gives
%the change of the performance metrics by increasing number of channel.

- Beta_dist.m: This is a sample script to calculate the performance of IRSA with the Beta distribution with the help of function "irsa_beta.m", which uses the fixed number of channel throughout the whole simulation time.

- ComparisonBetawithPoisson.m: This is a sample script to compare the performance of IRSA with fixed channel number throughout 10 second between Beta and Poisson distribution. The distributions have same loads.

- Beta_diff_channel.m: A script to run the function "irsa_beta_different_channel.m" with different Random Access Frame Lengths and different discrete time-step lengths. Remember: irsa_beta_different_channel.m function uses optimum channel number in each discrete time-step.

- Beta_diff_channel2.m: A script to run the function "irsa_beta_different_channel.m" with  different discrete step-size and different subcarrier spacing. In 5G, allowed subcarrier spacing is limeted with 15, 30, 60, 120, 240 kHZ. In the paper, we defined latency = waiting time + 2*frame length. We assumed the waiting time is constant and equal to zero for all subcarrier spacings to have a good comprasion. Then, we find the random access frame length based on different subcarrier spacings under the constaint that all systems use same amount of resources. 

- Direct_Beta_scr.m: A sample script to run the function "Direct_Beta.m", which calculate the performance of IRSA with an exact Beta distribution.
