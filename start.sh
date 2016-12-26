#!/bin/bash

function get_ip (){
    /sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'
}

function get_ext_ip (){
    if [ ! -z "$EXTIP"]; then
      echo $EXTIP $URL >> /etc/hosts
      echo $EXTIP
    else
      getent hosts $URL | cut -d' ' -f1
    fi
}

IP=`get_ip`
EXT_IP=`get_ext_ip`

service redis-server start

if [ ! -z "$URL" ];then
    echo "Setting Hostname to " $URL
    bbb-conf --setip $URL
    sed -ri "s/(.*BigBlueButtonURL *= *\").*/\1http:\/\/$URL\/bigbluebutton\/\";/" /var/lib/tomcat7/webapps/demo/bbb_api_conf.jsp
else
    echo "Setting IP to " $IP
    bbb-conf --setip $IP
    sed -ri "s/(.*BigBlueButtonURL *= *\").*/\1http:\/\/$IP\/bigbluebutton\/\";/" /var/lib/tomcat7/webapps/demo/bbb_api_conf.jsp
fi

# Configure external IP specific settings
# /opt/freeswitch/conf/vars/xml
sed -ri "/<X-PRE-PROCESS cmd=\"set\" data=\"local_ip_v4=/d" /opt/freeswitch/conf/vars.xml
sed -ri "s/(<X-PRE-PROCESS cmd=\"set\" data=\"bind_server_ip=)(auto)/\1$EXT_IP/" /opt/freeswitch/conf/vars.xml
sed -ri "s/(<X-PRE-PROCESS cmd=\"set\" data=\"external_rtp_ip=)(stun:stun.freeswitch.org)/\1$EXT_IP/" /opt/freeswitch/conf/vars.xml
sed -ri "s/(<X-PRE-PROCESS cmd=\"set\" data=\"external_sip_ip=)(stun:stun.freeswitch.org)/\1$EXT_IP/" /opt/freeswitch/conf/vars.xml

# /opt/freeswitch/conf/sip_profiles/external.xml
sed -ri "/ext-rtp-ip/s/local_ip_v4/external_rtp_ip/g" /opt/freeswitch/conf/sip_profiles/external.xml
sed -ri "/ext-sip-ip/s/local_ip_v4/external_sip_ip/g" /opt/freeswitch/conf/sip_profiles/external.xml

# /usr/share/red5/webapps/sip/WEB-INF/bigbluebutton-sip.properties
sed -ri "s/(bbb\.sip\.app\.ip=).*/\1$IP/" /usr/share/red5/webapps/sip/WEB-INF/bigbluebutton-sip.properties
sed -ri "s/(freeswitch\.ip=).*/\1$IP/" /usr/share/red5/webapps/sip/WEB-INF/bigbluebutton-sip.properties

# /etc/bigbluebutton/nginx/sip.nginx
sed -ri "s/(proxy_pass http:\/\/).*(:.*)/\1$IP\2/" /etc/bigbluebutton/nginx/sip.nginx


# Start bbb 

#bbb-conf --enablewebrtc
bbb-conf --clean
bbb-conf --check

tail -f /var/log/bigbluebutton/*.log
