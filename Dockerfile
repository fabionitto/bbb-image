FROM ubuntu:14.04
MAINTAINER Fabio Nitto <fabio.nitto@gmail.com>

ENV FFMPEG_VERSION 2.3.3
ENV BUILD_PACKAGES \
    build-essential \
    checkinstall \
    git-core \
    libncurses5-dev \
    libvorbis-dev \
    libvpx-dev \
    libx11-dev \
    libxfixes-dev \
    netcat \
    pkg-config \
    texi2html \
    yasm \
    zlib1g-dev

#Add multiverse repo
RUN echo "deb http://us.archive.ubuntu.com/ubuntu/ trusty multiverse" | tee -a /etc/apt/sources.list

#Add LibreOffice 4.4 repo
RUN apt-get -y update && apt-get install -y \
    software-properties-common \
    language-pack-en-base && \
    export LC_ALL=en_US.UTF-8 && \
    export LANG=en_US.UTF-8 && \
    apt-add-repository ppa:libreoffice/libreoffice-4-4 && \
    apt-add-repository -y ppa:ondrej/php 

# Add bbb keys and repos
RUN apt-get -y update && apt-get install -y wget && \
    wget http://ubuntu.bigbluebutton.org/bigbluebutton.asc -O- | sudo apt-key add - && \
    echo "deb http://ubuntu.bigbluebutton.org/trusty-1-0/ bigbluebutton-trusty main" | sudo tee /etc/apt/sources.list.d/bigbluebutton.list

#Install build packages - compile ffmpeg
RUN apt-get -y update && apt-get install -y \
    $BUILD_PACKAGES &&  \
    cd /usr/local/src && \
    wget "http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2" && \
    tar -xjf "ffmpeg-${FFMPEG_VERSION}.tar.bz2" && \
    cd "ffmpeg-${FFMPEG_VERSION}" && \
    sudo ./configure --enable-version3 --enable-postproc --enable-libvorbis --enable-libvpx && \
    sudo make && \
    sudo checkinstall --pkgname=ffmpeg --pkgversion="5:${FFMPEG_VERSION}" --backup=no --deldoc=yes --default
    #&& \
    #AUTO_ADDED_PACKAGES=`apt-mark showauto` && \
    #apt-get remove --purge -y $BUILD_PACKAGES $AUTO_ADDED_PACKAGES

#Install Tomcat7 and setting custom init.d script
RUN apt-get -y update && apt-get install -y  \
    tomcat7

COPY tomcat7 /etc/init.d/tomcat7

#Install required packages
RUN apt-get -y update && apt-get install -y  \
    bigbluebutton \
    supervisor

RUN apt-get -y update && apt-get install -y \
    bbb-check \
    bbb-demo

# ImageMagick Security Policy OK

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start.sh /usr/bin/start.sh

RUN bbb-conf --enablewebrtc

EXPOSE 80 443 1935 5066 9123
CMD ["/usr/bin/start.sh"]
