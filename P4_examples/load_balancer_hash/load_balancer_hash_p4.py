#!/usr/bin/python
from mininet.net import Containernet
from mininet.node import Controller
from mininet.cli import CLI
from mininet.log import info, setLogLevel
from mininet.bmv2 import ONOSBmv2Switch, P4DockerHost
setLogLevel('info')


class NormalP4Switch(ONOSBmv2Switch):
    def __init__(self, name, **kwargs):
        ONOSBmv2Switch.__init__(self, name, **kwargs)
        self.netcfg = False


net = Containernet(controller=Controller, switch=NormalP4Switch)

info('*** Adding controller\n')
net.addController('c0')

info('*** Adding docker containers\n')

# Fake HOST
d1 = net.addDocker('d1', cls=P4DockerHost, ip='192.168.1.100',
                   dimage="containernet_example:ubuntup4", mac="00:00:00:00:00:01")
d1.start()
# HOST
h1 = net.addHost('h1', ip='192.168.1.104', mac="00:00:00:00:00:04")
h2 = net.addHost('h2', ip='192.168.1.105', mac="00:00:00:00:00:05")

# h4 = net.addDocker('h4', cls=P4DockerHost, ip='192.168.1.104',
#                   dimage="containernet_ubuntup4:latest", mac="00:00:00:00:00:04")
# h5 = net.addDocker('h5', cls=P4DockerHost, ip='192.168.1.105',
#                   dimage="containernet_ubuntup4:latest", mac="00:00:00:00:00:05")


# LAMP servers
d2 = net.addDocker('d2', cls=P4DockerHost, ip='192.168.1.200',
                   dimage="containernet_example:lamp", mac="00:00:00:00:00:A0")
d2.start()
d3 = net.addDocker('d3', cls=P4DockerHost, ip='192.168.1.201',
                   dimage="containernet_example:lamp", mac="00:00:00:00:00:A1")
d3.start()

info('*** Adding switches\n')

s1 = net.addSwitch('s1', json="./load_balancer_hash.json", loglevel="debug", pktdump=True)

info('*** Creating links\n')
net.addLink(d1, s1)
net.addLink(d2, s1)
net.addLink(d3, s1)
net.addLink(h1, s1)
net.addLink(h2, s1)
info('*** Starting network\n')

net.start()
net.staticArp()

info('*** Running CLI\n')
CLI(net)
info('*** Stopping network')
net.stop()
