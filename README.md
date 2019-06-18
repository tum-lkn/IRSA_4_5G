The simulation code used in the paper "System Level Integration of Irregular Repetition Slotted ALOHA for Industrial IoT in 5G New Radio" by H. Murat Gürsu, M. Cagatay Moroglu, Mikhail Vilgelm, Federico Clazzer, Wolfgang Kellerer for the PIMRC 2019 Istanbul.

Firstly we explain the re-used code.

IRSA algorithm is taken from https://github.com/afcuttin/irsa, which includes 
the files: LICENSE, generateTwins.m, irsa.m, sampleIrsaScript.m and sic.m.

Functions:

- irsa.m calculates the normalized load,the normalized throughput and packet loss 
Rate by using single channel, with given parameters "sourceNumber, randomAccessFrameLength, packetReadyProb, maxRepetitionRate, simulationTime, maxIter".
Note: We updated this function by adding two more degree distribution.

- GenerateTwins.m return the MAC frame includes twins.

- sic.m makes successive interference cancelation, and returns MAC frame with unsolved packets, solved users, and solved packets information.

Scripts:

- sampleIrsaScript.m is a sample script for IRSA.



------------------------------------------------------------------------------
Secondly the following introduces the simulator we developped for NR integration. The flow chart introduces introduction of each function.

![Function Flow Chart](https://github.com/tum-lkn/IRSA_4_5G/blob/master/FlowChart.jpg)


Functions:

- multichannelIRSA.c: In this function, each user randomly selects a channel out of ChannelNumber usable channels. The IRSA simulation is run for each channel separately. The performance metrics from all channels are averaged over all channels.

- irsa_beta.m: This function investigates the time based behavior of arrivals for MC-IRSA. At each time instant it uses multichannelIRSA.c to simulate multiple channel IRSA during the period of one multichannel IRSA-frame. The beta distribution used in sumulations is based on the reference [21] in the manuscript. This distribution is discretized with a selected time step. Lastly, the average normalized Load, normalized Throughput, and PLR vectors are calculated over different time-instances. FIXED number of channels is used throughout the simulation. 


- irsa_poisson.m: This function is same as irsa_beta.m but using Poisson distribution instead of Beta distribution.


- optimize_numberOfChannel.m: This function calculates the optimum number of channel for a given number of users, randomAccessFrameLength, and degree distribution under the constraints of maxChannelNumber and Packet Loss Rate of 0.1 for MC-IRSA.

- optimize_numberOfChannel_2.m: This function is similar to the function "optimize_numberOfChannel.m". This function is for for AMC-IRSA.

- irsa_beta_different_channel.m: This function investigates the time based behavior of arrivals for AMC-IRSA. At each time instant it uses multichannelIRSA.c to simulate multiple channel IRSA during the period of one multichannel IRSA-frame. The beta distribution used in sumulations is based on the reference [21] in the manuscript. This distribution is discretized with a selected time step. Lastly, the average normalized Load, normalized Throughput, and PLR vectors are calculated over different time-instances. FIXED number of channels is used throughout the simulation. 

Scripts:

- Multichannel.m: A sample script to run the function "multichannelIRSA.m", which gives the change in the performance metrics by increasing number of channel.

- Beta_dist.m: This is a sample script to calculate the performance of IRSA with the Beta distribution with the help of function "irsa_beta.m", which uses the fixed number of channel throughout the whole simulation time.

- ComparisonBetawithPoisson.m: This is a sample script to compare the performance of IRSA with fixed channel number throughout 10 second between Beta and Poisson distribution. The distributions have same loads.

- Beta_diff_channel.m: A script to run the function "irsa_beta_different_channel.m" with different Random Access Frame Lengths and different discrete time-step lengths. Remember: irsa_beta_different_channel.m function uses optimum channel number in each discrete time-step.

- Beta_diff_channel2.m: A script to run the function "irsa_beta_different_channel.m" with  different discrete step-size and different subcarrier spacing. In 5G, allowed subcarrier spacing is limeted with 15, 30, 60, 120, 240 kHZ. In the paper, we defined latency = waiting time + 2*frame length. We assumed the waiting time is constant and equal to zero for all subcarrier spacings to have a good comprasion. Then, we find the random access frame length based on different subcarrier spacings under the constaint that all systems use same amount of resources. 

- Direct_Beta_scr.m: A sample script to run the function "Direct_Beta.m", which calculate the performance of IRSA with an exact Beta distribution.
