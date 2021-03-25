#!/bin/bash

#Build libbpf
sudo apt install -y libelf-dev clang
cd ~/p4c/backends/ebpf/
sudo ./build_libbpf

#Clone
cd ~/p4c/
mkdir extensions
cd extensions
git clone https://github.com/vmware/p4c-xdp.git
ln -s ~/p4c p4c-xdp/p4c

#Make
cd ~/p4c/
mkdir -p build
cd build/
cmake ..
make

#Make soft links
cd ~/p4c/extensions/p4c-xdp
ln -s ~/p4c/build/p4c-xdp p4c-xdp
ln -s ~/p4c/backends/ebpf/run-ebpf-test.py run-ebpf-test.py

#Run tests
cd ~/p4c/build/
make check-xdp

#Add needed env variables and load configuration
echo "Adding env variables to .profile ..."
echo 'export P4C="$HOME/p4c"' >> $HOME/.profile
echo 'export PATH="$P4C/extensions/p4c-xdp:$PATH"' >> $HOME/.profile