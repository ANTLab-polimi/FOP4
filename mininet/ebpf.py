import os

from mininet.log import info, error
from mininet.node import Host


class EbpfXdpNode(Host):
    """
    eBPF XDP node is an enhanced Mininet host that allows to install a specified XDP eBPF program on interfaces.
    It can load the default eBPF program or another one specified when loading.
    """

    def __init__(self, name, ebpfProgram=None, **kwargs):
        self.defEbpfProgram = ebpfProgram
        self.ebpfProgramsDict = {}

        # call original Host.__init__
        Host.__init__(self, name, **kwargs)

    def loadEbpfOnInterface(self, ebpfProgram=None, intf=None):
        """
        Load the eBPF program on the interface
        :param ebpfProgram:
        :param intf:
        :return:
        """
        ebpfProgram = self.defEbpfProgram if ebpfProgram is None else ebpfProgram
        if ebpfProgram is None:
            # Load the default eBPF Program
            error("No default eBPF program\n")
            return
        #TODO: what happen if the intf passed does not exist?
        intf_name = self.defaultIntf().name if intf is None else self.intf(intf).name
        if os.path.isfile(os.path.expanduser(ebpfProgram)):
            # TODO: check the output of the loading
            out = self.cmd("ip link set dev " + intf_name + " xdp obj " + ebpfProgram + " verb")
            info("%s loaded in %s\n" % (ebpfProgram, intf_name))
            self.ebpfProgramsDict[self.intf(intf_name)] = ebpfProgram
        else:
            error("%s is not a file\n" % ebpfProgram)

    def unloadEbpfProgram(self, intf=None, ebpfProgram=None):
        """
        Unload the eBPF program from the specified interface
        :param intf:
        :return:
        """
        if ebpfProgram is not None:
            intf_name = ""
            for k, v in self.ebpfProgramsDict.items():
                if v == ebpfProgram:
                    intf_name = k.name
                    break
            if intf_name == "":
                error("%s not loaded in any interface\n" % ebpfProgram)
                return
        elif self.intf(intf) in self.ebpfProgramsDict.keys():
            intf_name = self.intf(intf).name
        else:
            error("In %s no eBPF program is loaded\n" % self.intf(intf))
            return

        self.cmd("ip link set dev " + intf_name + " xdp off")

        # Remove the unloaded eBPF program from the dict
        self.ebpfProgramsDict.pop(self.intf(intf_name))
