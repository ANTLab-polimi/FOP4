#!/usr/bin/python
"""
This is the most simple example to showcase Containernet.
"""
from mininet.net import Containernet
from mininet.node import Controller
from mininet.cli import CLI
from mininet.link import TCLink
from mininet.log import info, setLogLevel
setLogLevel('info')

net = Containernet(controller=Controller)
info('*** Adding controller\n')
net.addController('c0')
info('*** Adding docker containers\n')
# IPC see: https://docs.docker.com/engine/reference/run/#ipc-settings---ipc
d1 = net.addDocker('d1', ip='10.0.0.251', dimage="ubuntu:trusty", ipc_mode="shareable", devices=["/dev/net/tun"])  # share IPC
d2 = net.addDocker('d2', ip='10.0.0.252', dimage="ubuntu:trusty", ipc_mode="container:mn.d1", devices=["/dev/net/tun"])  # container:<name_or_id>
info('*** Adding switches\n')
s1 = net.addSwitch('s1')
s2 = net.addSwitch('s2')
info('*** Creating links\n')
net.addLink(d1, s1)
net.addLink(s1, s2, cls=TCLink, delay='100ms', bw=1)
net.addLink(s2, d2)
info('*** Starting network\n')
net.start()
info('*** Testing connectivity\n')
net.ping([d1, d2])
info('*** Running CLI\n')
CLI(net)
info('*** Stopping network')
net.stop()

