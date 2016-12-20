#!/bin/bash

function get_ip (){
    /sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'
}

IP=`get_ip`

service redis-server start

if [ ! -z "$URL" ];then
    bbb-conf --setip $URL
    sed -ri "s/(.*BigBlueButtonURL *= *\").*/\1http:\/\/$URL\/bigbluebutton\/\";/" /var/lib/tomcat7/webapps/demo/bbb_api_conf.jsp
else
    bbb-conf --setip $IP
    sed -ri "s/(.*BigBlueButtonURL *= *\").*/\1http:\/\/$IP\/bigbluebutton\/\";/" /var/lib/tomcat7/webapps/demo/bbb_api_conf.jsp
fi


#bbb-conf --enablewebrtc

bbb-conf --clean
bbb-conf --check

tail -f /var/log/bigbluebutton/*.log
