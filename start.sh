#!/bin/bash

function get_ip (){
    /sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'
}

IP=`get_ip`

bbb-conf --setip $IP

bbb-conf --enablewebrtc

bbb-conf --clean
bbb-conf --check
