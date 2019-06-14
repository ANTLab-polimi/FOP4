# extended INT (eINT) with VNFs support

## Demo architecture

![Scenario3](https://github.com/ANTLab-polimi/FOP4/raw/master/P4_examples/eINT/doc/UC3_2.png)

## Example of functionality
![Scenario3Example](https://github.com/ANTLab-polimi/FOP4/raw/master/P4_examples/eINT//doc/UC3_1.png)


## Demo walkthorough

### Step 1: Add int-vnf

```sh
cd int-vnf/
./buid.sh
```

### Step 2: Start FOP4 topology


```sh
sudo python eint_topology.py

# check if things run in FOP4:
containernet> dump
<P4Host h1: h1-eth0:10.0.0.1 pid=14102> 
<P4Host h2: h2-eth0:10.0.0.2 pid=14104> 
<P4Host h3: h3-eth0:10.0.0.254 pid=14106> 
<P4DockerHost v1: v1-eth0:10.0.0.100,v1-eth1:None pid=14149> 
<P4DockerHost v2: v2-eth0:10.0.0.101,v2-eth1:None pid=14289> 
<ONOSBmv2Switch s1: lo:127.0.0.1,s1-eth1:None,s1-eth2:None pid=14391> 
<ONOSBmv2Switch s2: lo:127.0.0.1,s2-eth1:None,s2-eth2:None,s2-eth3:None,s2-eth4:None pid=14395> 
<ONOSBmv2Switch s3: lo:127.0.0.1,s3-eth1:None,s3-eth2:None,s3-eth3:None,s3-eth4:None pid=14399> 
<ONOSBmv2Switch s4: lo:127.0.0.1,s4-eth1:None,s4-eth2:None,s4-eth3:None pid=14403> 

# check Docker status
$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
2f3585b0c837        fop4_example:eINT   "/bin/bash"         53 seconds ago      Up 52 seconds                           mn.v2
ac083b30a046        fop4_example:eINT   "/bin/bash"         54 seconds ago      Up 54 seconds                           mn.v1

```

### Step 3: Test connectivity

#### Terminal
Test iperf UDP connectivity between the 2 hosts. `h1` is the Traffic Source, `h2` is the traffic sink

```sh
h2 iperf -u -s &
h1 iperf -u -l 1200 -c 10.0.0.2
```

