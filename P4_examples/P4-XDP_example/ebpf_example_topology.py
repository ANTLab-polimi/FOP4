#!/usr/bin/python
from mininet.net import Containernet
from mininet.cli import CLI
from mininet.log import info, setLogLevel
setLogLevel('info')

net = Containernet()

info('*** Adding Controller\n')
c = net.addController()

info('*** Adding Hosts\n')

# HOST
h1 = net.addHost('h1')
h2 = net.addEbpfHost('h2')

info('*** Adding switches\n')

s1 = net.addSwitch('s1')

info('*** Creating links\n')
net.addLink(h1, s1)
net.addLink(h2, s1, ebpfProgram1="./program.o")
info('*** Starting network\n')

net.start()
net.staticArp()

info('*** Running CLI\n')
CLI(net)
info('*** Stopping network')
net.stop()
