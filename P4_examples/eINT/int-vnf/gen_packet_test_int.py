#!/usr/bin/python
from scapy.all import *
import time
import argparse

from int_header import INT_v10

if __name__ == "__main__":
    p1 = Ether() / \
         IP(src="10.0.0.1", dst="10.0.0.2") / \
         UDP(sport=5000, dport=5000) / \
         INT_v10(length=6, hopMLen=4, remainHopCnt=3,
                 # ver=1,
                 ins=0b11110000,
                 vnf_ins=0b11100000,
                 # reserved=0,
                 INTMetadata=[100,100,100],
                 ) / \
         Raw(load="0"*40)

    iface = "veth1"

    try:
        while 1:
            # sendp(p0, iface=iface)
            # time.sleep(2)
            sendp(p1, iface=iface)
            time.sleep(2)

    except KeyboardInterrupt:
        pass
