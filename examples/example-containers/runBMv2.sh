#!/bin/bash

#INTF_LIST=`ls -l /sys/class/net | grep nw | awk '{print $9}'`
INTF_LIST=`ls -l /sys/class/net | grep root | awk '{print $9}'`
n=1
INTF_SW=""
for i in $INTF_LIST
do
	INTF_SW="$INTF_SW -i $n@$i"
	n=$(($n+1))
done
echo $INTF_SW
simple_switch_grpc --log-console --no-p4 $INTF_SW
#echo $INTF_SW