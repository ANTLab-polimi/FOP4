#!/bin/bash

python ./sniff.py --in_intf $(hostname)'-eth0' --out_intf $(hostname)'-eth1'  --vnf_id 1
