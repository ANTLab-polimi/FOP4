# UC3: extended INT (eINT) with VNFs support

## Demo architecture

![Scenario3](https://github.com/ANTLab-polimi/UC-P4Containernet/raw/master/uc3_int/doc/UC3_2.png)

## Example of functionality
![Scenario3Example](https://github.com/ANTLab-polimi/UC-P4Containernet/raw/master/uc3_int/doc/UC3_1.png)


## Demo walkthorough

### Step 1: Start Containernet topology

```sh
sudo python uc3_topology.py

# check if things run in Containernet:
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
2f3585b0c837        p4c-vnf-int         "/bin/bash"         53 seconds ago      Up 52 seconds                           mn.v2
ac083b30a046        p4c-vnf-int         "/bin/bash"         54 seconds ago      Up 54 seconds                           mn.v1

```

### Step 3: Test connectivity

#### Terminal
Test iperf UDP connectivity between the 2 hosts. `h1` is the Traffic Source, `h2` is the traffic sink

```sh
h2 iperf -u -s &
h1 iperf -u -l 1200 -c 10.0.0.2
```

