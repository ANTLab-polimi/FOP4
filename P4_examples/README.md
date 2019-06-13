# P4 examples on FOP4

## Pre-requisites

To run these examples you need to have installed both `p4c` and `behavioural-model` with **P4Runtime** support.

You can follow the guide provided by *p4.org*.

* `p4c`: you need to install the P4 compiler following [this guide](https://github.com/p4lang/p4c)
* `behavioural-model`: you need to install `simple_switch_grpc` following [this guide](https://github.com/p4lang/behavioral-model/tree/master/targets/simple_switch_grpc) (remember to install also **P4Runtime**)

Alternatively, you can use the [ONF script](https://github.com/opennetworkinglab/onos/blob/master/tools/dev/p4vm/install-p4-tools.sh) that should install both `p4c` and `behavioural-model` with support to P4Runtime.

See [here](https://github.com/jafingerhut/p4-guide/blob/master/bin/README-install-troubleshooting.md) for troubleshooting.

## Topology

2 Hosts:

* h1) IP: 192.168.1.104, MAC: 00:00:00:00:00:04
* h2) IP: 192.168.1.105, MAC: 00:00:00:00:00:05

1 *"Fake"* Host (Docker Image: containernet_example:ubuntup4)

* d1) IP: 192.168.1.100, MAC: 00:00:00:00:00:01

2 LAMP SERVER (Docker image: containernet_example:lamp)

* d2) IP: 192.168.1.200, MAC: 00:00:00:00:00:A0
* d3) IP: 192.168.1.201, MAC: 00:00:00:00:00:A1

1 Switch P4:

* It will be loaded with the pipeline load_balancer_RR or load_balancer_hash

## Instructions

First you need to compile the P4 pipeline using the `make` command on the folders `load_balancer_hash` and `load_balancer_RR`.

Then you can run the script `load_balancer_hash_p4.py` or the script `load_balancer_RR_p4.py` to run the previously described topology.

Finally, you need to populate the tables of the switch using the command `simple_switch_CLI --thrift-port $(cat /tmp/bmv2-s1-thrift-port) < command.txt`.

If you try to contact the LAMP webserver at the address 192.168.1.100 you will be served alternatively from the host with IP 192.168.1.200 or the host with IP 192.168.1.201.
To check it you can try to open the page `index.php` and you can check the address of the server that served the page (search for **SERVER_ADDR** field).

## Miniedit.py

You can use a GUI using `miniedit.py` script on the `example` folder of this repository, this script has support for P4 BMv2 switches.
