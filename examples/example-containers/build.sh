#!/bin/bash

docker build -t containernet_example:ubuntu1404 -f Dockerfile.ubuntu1404 .
docker build -t containernet_example:ubuntu1604 -f Dockerfile.ubuntu1604 .
docker build -t containernet_example:ubuntu1804 -f Dockerfile.ubuntu1804 .

docker build -t containernet_example:centos6 -f Dockerfile.centos6 .
docker build -t containernet_example:centos7 -f Dockerfile.centos7 .


docker build -t containernet_example:lamp -f Dockerfile.lamp .
docker build -t containernet_example:haproxy -f Dockerfile.HAProxy .
docker build -t containernet_example:ubuntup4 -f Dockerfile.ubuntu_p4 .

docker build -t containernet_example:nDPI -f Dockerfile.nDPI .