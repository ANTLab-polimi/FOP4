# FOP4: Function Offloading Prototyping with P4

This fork of Mininet and Containernet allows to use Docker containers and P4-enabled devices like P4-switches and SmartNIC. This allows to build and experiment function offloading prototypes.

Containernet is a fork of the famous [Mininet](http://mininet.org) network emulator and allows to use [Docker](https://www.docker.com) containers as hosts in emulated network topologies. This enables interesting functionalities to build networking/cloud emulators and testbeds. One example for this is the [NFV multi-PoP infrastructure emulator](https://github.com/sonata-nfv/son-emu) which was created by the [SONATA-NFV](http://sonata-nfv.eu) project and is now part of the [OpenSource MANO (OSM)](https://osm.etsi.org) project. Besides this, Containernet is actively used by the research community, focussing on experiments in the field of cloud computing, fog computing, network function virtualization (NFV), and multi-access edge computing (MEC).

Based on: **Mininet 2.3.0d5**

* Containernet website: https://containernet.github.io/
* Mininet website:  http://mininet.org
* Original Mininet repository: https://github.com/mininet/mininet

---
## Cite this work

If you use FOP4 for your research and/or other publications, please cite (beside the original Mininet paper) the following paper to reference our work:

---
## Features

* Add, remove Docker containers to Mininet topologies
* Add, remove P4-enabled switches to Mininet topologies
* Add, remove eBPF-XDP hosts to Mininet topologies
* Connect Docker containers to topology (to switches, other containers, or legacy Mininet hosts)
* Execute commands inside Docker containers by using the Mininet CLI
* Dynamic topology changes (lets behave like a small cloud ;-))
   * Add Hosts/Docker containers/P4-switches/eBPF hosts to a *running* Mininet topology
   * Connect Hosts/Docker containers/P4-switches/eBPF hosts containers to a *running* Mininet topology
   * Remove Hosts/Docker containers/P4-switches/eBPF hosts containers/Links from a *running* Mininet topology
* Resource limitation of Docker containers
   * CPU limitation with Docker CPU share option
   * CPU limitation with Docker CFS period/quota options
   * Memory/swap limitation
   * Change CPU/mem limitations at runtime!
* Expose container ports and set environment variables of containers through Python API
* Traffic control links (delay, bw, loss, jitter)
* Automated installation based on Ansible playbook

---
## Installation
For a smooth installation process, it is suggested to install FOP4 and P4 tools in the root of your home directory. The following instructions will guide you in the process: 
```bash
$ cd
$ git clone https://github.com/ANTLab-polimi/FOP4.git
$ cd FOP4
```

### P4 tools (Dependencies)
P4 tools are necessary to run the P4 examples included with FOP4 and to be able to use all of its features. It's highly reccomended to use the included script to automate the installation of a compatible version:

* Requires a clean instance of **Ubuntu Linux 20.04 LTS** with the following minimum specs:
    * At least 2GB of RAM
    * At least 12GB of **FREE** disk space 
```bash
$ cd util
$ ./install-p4-dependencies.sh
$ cd ..
```
**WARNING:** It may take over an hour for this installation to complete

The script will add the tools folders to PATH through your bash profile file.
To load them without rebooting, run `source ~/.profile`

### XDP backend for P4C
If you also intend to use [p4c-xdp](https://github.com/vmware/p4c-xdp) (an XDP backend for P4C) it can be installed using the included script.
```bash
$ cd util
$ ./install-p4c-xdp.sh
$ cd ..
```

The script will add necessary environment variables to your bash profile file.
To load them without rebooting, run `source ~/.profile`

### FOP4

* Requires **Ubuntu Linux 20.04 LTS**, **Python3** and **P4 tools**.
* If P4 tools have been installed with the provided script, the machine is already configured to install FOP4 without additional requirements.

```bash
$ cd ansible
$ sudo apt-get install -y ansible aptitude
$ sudo ansible-playbook -i "localhost," -c local install.yml
$ cd ..
$ sudo python3 setup.py install
```
Wait (and have a coffee) ...

---
## Examples

### Usage example (using bare-metal installation)

Start example topology with some empty Docker containers connected to the network.

* `cd FOP4`
* run: `sudo python3 examples/containernet_example.py`
* use: `containernet> d1 ifconfig` to see config of container `d1`
* use: `containernet> d1 ping -c4 d2` to ping between containers

### Topology example

In your custom topology script you can add Docker hosts as follows:

```python
info('*** Adding docker containers\n')
d1 = net.addDocker('d1', ip='10.0.0.251', dimage="ubuntu:trusty")
d2 = net.addDocker('d2', ip='10.0.0.252', dimage="ubuntu:trusty", cpu_period=50000, cpu_quota=25000)
d3 = net.addHost('d3', ip='11.0.0.253', cls=Docker, dimage="ubuntu:trusty", cpu_shares=20)
d4 = net.addDocker('d4', dimage="ubuntu:trusty", volumes=["/:/mnt/vol1:rw"])
```

You can add P4-enabled switch as follows:
```python
info('*** Adding P4 switches\n')
# add P4 switch with Thrift-based interface
s1 = net.addP4Switch(name="S1", netcfg=False,
    json="example_p4.json",
    switch_config="switch_config.cfg")

# add P4 switch controlled by ONOS
s2 = net.addP4Switch(name="S2",
    pipeconf="org.onosproject.pipelines.basic")
```

You can add eBPF Host as follows:
```python
info('*** Adding eBPF host\n')
enf1 = net.addEbpfHost("ENF1")
net.addLink(enf1, s2,
    ebpfProgram1="./ebpf_program.o")
```

### Tests

```sh
sudo make test
```

---
## Documentation

Containernet's [documentation](https://github.com/containernet/containernet/wiki) can be found in the [GitHub wiki](https://github.com/containernet/containernet/wiki). The documentation for the underlying Mininet project can be found [here](http://mininet.org/).

---
## Contact

### Support

If you have any questions, please use GitHub's [issue system](https://github.com/ANTLab-polimi/FOP4/issues)

### Contribute

Your contributions are very welcome! Please fork the GitHub repository and create a pull request.

### Lead developers

Daniele Moro
* Mail <daniele (dot) moro (at) polimi (dot) it>
* Github: [@daniele-moro](https://github.com/daniele-moro)

Manuel Peuster
* Mail: <manuel (at) peuster (dot) de>
* Twitter: [@ManuelPeuster](https://twitter.com/ManuelPeuster)
* GitHub: [@mpeuster](https://github.com/mpeuster)
* Website: [https://peuster.de](https://peuster.de)
