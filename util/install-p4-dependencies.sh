#!/bin/bash

############
# Tested on a clean Ubuntu 20.04 LTS installation
#
# Required specs:
# - At least 2GB of RAM
# - At least 12GB of FREE disk space
############

#Install everything in the home directory
cd

#Install basic packages
sudo apt update

#Install dependencies with the script from https://github.com/jafingerhut/p4-guide/blob/master/bin/README-install-troubleshooting.md
git clone https://github.com/jafingerhut/p4-guide
./p4-guide/bin/install-p4dev-v4.sh |& tee dependencies_log.txt

#Add paths to environment
cat p4setup.bash >> .profile

#Uninstall mininet pip package installed by the script, it will be substituded by the one of Containernet
#Otherwise 'sudo python3 setup.py install' doesn't work correctly
sudo pip3 uninstall -y mininet