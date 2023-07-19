# DDoS-Attack
DDoS attacks are Distributed Denial of Service attacks often done these days.
The goal of this type of attacks is to occupy the server victim with irrelevant
request thus keeping the victim from giving service of legitimate clients.

The purpose of the paper and this simulation is to study the impact of DDoS attacks with
regard to two parameters. The first parameter is the intensity of the attack, which means
the volume of the attack’s rate. The second parameter is the buffer size of network
components. Moreover, this simulation is measuring the impact of DDoS attacks in large-
scale networks with random distribution of DDoS zombies.

## Overview
The system consists of twenty devices and six routers. The network is build of 5 LANs(local
area network), each LAN contains four devices and one router that connects the LAN to the
internet. Router zero represent the ‘internet’. The program uses 3 simple modules in order
to build the compound modules in the network:
- App- responsible to generate traffic and receiving packets.
- L2Quene- represents the network interface for point to point connection. Packets that
arrive while a previous packet is being transmitted are queued up.
- Routing- responsible for routing packets according to the destination address given in the
header of the packet. It contains a routing table that is built at the beginning of the
simulation.

## How to run the project
The project is written for the OMNeT++ simulation enviroment, meaning in order to run 
the project one needs OMNeT++ and to run the ini file.
