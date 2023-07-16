//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/.
//

simple App
{
    parameters:
        int zombie;
        int victim;
        int address;  // local node address
        string destAddresses;  // destination addresses
        volatile double sendIaTime @unit(s) = default(exponential(1s)); // time between generating packets
     	volatile double zombieTime @unit(s) = default(exponential(0.1s)); //time between generatin packets for zombies
        volatile int packetLength @unit(byte);  // length of one message (fixed! no "volatile" modifier)
        @display("i=block/browser");
        @signal[endToEndDelay](type="simtime_t");
        @signal[hopCount](type="long");
        @signal[sourceAddress](type="long");
        @statistic[endToEndDelay](title="end-to-end delay of arrived packets"; unit=s; record=vector,mean,max; interpolationmode=none);
        @statistic[hopCount](title="hop count of arrived packets"; interpolationmode=none; record=vector?,mean,max);
        @statistic[sourceAddress](title="source address of arrived packets"; interpolationmode=none; record=vector?);
    gates:
        input in;
        output out;
}


simple Routing
{
    parameters:
        @display("i=block/switch");
        @signal[drop](type="long");
        @signal[outputIf](type="long");
        @statistic[drop](title="dropped packet byte length"; unit=bytes; record=vector?,count,sum; interpolationmode=none);
        @statistic[outputIf](title="output interface for each routed packet"; record=histogram; interpolationmode=none);
    gates:
        input in[];
        output out[];
        input localIn;
        output localOut;
}


simple L2Queue
{
    parameters:
        int frameCapacity = default(0); // max number of packets; 0 means no limit
        bool useCutThroughSwitching = default(false);  // use cut-through switching instead of store-and-forward
        @display("i=block/queue;q=queue");
        @signal[qlen](type="long");
        @signal[busy](type="bool");
        @signal[queueingTime](type="simtime_t");
        @signal[drop](type="long");
        @signal[txBytes](type="long");
        @signal[rxBytes](type="long");
        @statistic[qlen](title="queue length"; record=vector?,timeavg,max; interpolationmode=sample-hold);
        @statistic[busy](title="server busy state"; record=vector?,timeavg; interpolationmode=sample-hold);
        @statistic[queueingTime](title="queueing time at dequeue"; unit=s; interpolationmode=none);
        @statistic[drop](title="dropped packet byte length"; unit=bytes; record=vector?,count,sum; interpolationmode=none);
        @statistic[txBytes](title="transmitting packet byte length"; unit=bytes; record=vector?,count,sum,histogram; interpolationmode=none);
        @statistic[rxBytes](title="received packet byte length"; unit=bytes; record=vector?,count,sum,histogram; interpolationmode=none);
    gates:
        input in;
        output out;
        inout line;
}


module Node
{
    parameters:
        int address;
        @display("i=device/pc,#0080FF;bgb=263,315");
    gates:
        inout port[];
    submodules:
        app: App {
            parameters:
                address = address;
                @display("p=142,41");
        }
        routing: Routing {
            parameters:
                @display("p=140,130");
            gates:
                in[sizeof(port)];
                out[sizeof(port)];
        }
        queue[sizeof(port)]: L2Queue {
            parameters:
                @display("p=80,200,row");
        }
    connections:
        routing.localOut --> app.in;
        routing.localIn <-- app.out;
        for i=0..sizeof(port)-1 {
            routing.out[i] --> queue[i].in;
            routing.in[i] <-- queue[i].out;
            queue[i].line <--> port[i];
        }
}



network net
{
    @display("bgi=maps/world;bgb=800,400,,,0");
    submodules:
        router[6]: Node {
            address = 100 + index;
            @display("i=abstract/router");
        }
        host[20]: Node{
            address = index;
        }
    connections:
        for i=1..5 {
            router[i].port++ <--> {  datarate = 1Mbps; } <--> router[0].port++;
        }

        for i=1..5, for j=0..3 {
            router[i].port++ <--> {  datarate = 1Mbps; } <--> host[(i-1)*4+j].port++;
        }
        router[1].port++ <--> {  datarate = 1Mbps; } <--> router[2].port++;
        router[1].port++ <--> {  datarate = 1Mbps; } <--> router[5].port++;
        router[2].port++ <--> {  datarate = 1Mbps; } <--> router[3].port++;
        router[3].port++ <--> {  datarate = 1Mbps; } <--> router[4].port++;
        router[4].port++ <--> {  datarate = 1Mbps; } <--> router[5].port++;

}

