# bbb-image
BigBlueButton Docker Image

# Usage

Usage of cap-add is necessary as freeswitch needs to set ulimits and nice.
So you need to run docker with --cap-add parameters

``
docker run --cap-add=SYS_NICE --cap-add=SYS_RESOURCE -p 80:80 fabionitto/bigbluebutton:0.1
``
