#!/usr/bin/python
from mininet.net import Containernet
from mininet.cli import CLI
from mininet.log import info, setLogLevel
from mininet.bmv2 import ONOSBmv2Switch, P4DockerHost, P4Host, Bmv2Switch
setLogLevel('info')

net = Containernet(switch=Bmv2Switch)

info('*** Adding docker containers\n')

# HOSTS
h1 = net.addHost('h1', cls=P4Host, ip='10.0.0.1', mac="00:00:00:00:00:01")
h2 = net.addHost('h2', cls=P4Host, ip='10.0.0.2', mac="00:00:00:00:00:02")

# INT COLLECTOR
h3 = net.addHost('h3', cls=P4Host, ip='10.0.0.254', mac="00:00:00:00:00:FF")


v1 = net.addDocker('v1', cls=P4DockerHost, ip='10.0.0.100', mac="00:00:00:00:00:F1", dimage='fop4_example:eINT')
v2 = net.addDocker('v2', cls=P4DockerHost, ip='10.0.0.101', mac="00:00:00:00:00:F2", dimage='fop4_example:eINT')

info('*** Adding switches\n')
# SWITCHES
s1 = net.addP4Switch(name='s1', json="./int.json", loglevel='debug', pktdump=False,
                     switch_config='./commands_INT_s1.txt')
s2 = net.addP4Switch(name='s2', json="./int.json", loglevel='debug', pktdump=False,
                     switch_config='./commands_INT_s2.txt')
s3 = net.addP4Switch(name='s3', json="./int.json", loglevel='debug', pktdump=False,
                     switch_config='./commands_INT_s3.txt')
s4 = net.addP4Switch(name='s4', json="./int.json", loglevel='debug', pktdump=False,
                     switch_config='./commands_INT_s4.txt')

# LINKS
info('*** Creating links\n')
net.addLink(h1, s1)
net.addLink(s1, s2)

net.addLink(s2, s3)
net.addLink(s2, v1)
net.addLink(s2, v1)

net.addLink(s3, s4)
net.addLink(s3, v2)
net.addLink(s3, v2)

net.addLink(h2, s4)
net.addLink(s4, h3)

info('*** Starting network\n')

net.start()
net.staticArp()

# Start containers
v1.start()
v2.start()

info('*** Running CLI\n')
CLI(net)
info('*** Stopping network')
net.stop()
