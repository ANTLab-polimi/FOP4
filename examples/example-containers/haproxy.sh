#!/bin/bash

echo "Starting server...."
haproxy -f /usr/local/etc/haproxy/haproxy.cfg
echo ".... done."