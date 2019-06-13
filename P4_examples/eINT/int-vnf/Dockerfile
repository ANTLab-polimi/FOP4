FROM ubuntu:xenial
MAINTAINER daniele.moro@polimi.it

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install -y -q \
	net-tools \
	iproute \
	inetutils-ping \
	iptables \
	arptables \
	ebtables \
	bridge-utils \
	ethtool \
	vim \
	tcpdump \
	python \
	python-pip \
	python-psutil

RUN pip install scapy

ADD sniff.py sniff.py
ADD int_header.py int_header.py
ADD start.sh start.sh
RUN chmod +x start.sh

# normal entry point
CMD ./start.sh
