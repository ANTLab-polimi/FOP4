import os

from mininet.log import info
from mininet.node import Host


class EbpfXdpNode(Host):
    """
    eBPF XDP node is an enhanced Mininet host that install XDP eBPF program on the default interface.
    It can have just maximum 2 interfaces (one connected to a switch and the other to an host
    """

    def __init__(self, name, ebpfXdpProgram, ebpfXdpInft=None, **kwargs):
        self.ebpfXdpProgram = ebpfXdpProgram

        self.ebpfXdpInft = ebpfXdpInft

        # call original Node.__init__
        Host.__init__(self, name, **kwargs)



    def setEbpfXdp(self):
        info('*** Running START EBPF\n')
        intf_name = self.intf(self.ebpfXdpInft).name
        if not os.path.isfile(self.ebpfXdpProgram):
            self.cmd("ip link set dev " + intf_name + " xdp obj " + self.ebpfXdpProgram + " verb")
            info("%s loaded in %s" % (self.ebpfXdpProgram, intf_name))

    def config( self, **_params ):
        r = Host.config(self, **_params )
        self.setEbpfXdp()
        return r
