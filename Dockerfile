FROM ubuntu:14.04
MAINTAINER Fabio Nitto <fabio.nitto@gmail.com>

RUN update-locale LANG=en_US.UTF-8 && dpkg-reconfigure locales

#Install build packages - compile ffmpeg
RUN apt-get -y update && apt-get install -y \
    build-essential \
    git-core \
    checkinstall \
    yasm \
    texi2html \
    libvorbis-dev \
    libx11-dev \
    libvpx-dev \
    libxfixes-dev \
    zlib1g-dev \
    pkg-config \
    netcat \
    libncurses5-dev
    
#Purge build packages

# Add bbb keys and repos
RUN wget http://ubuntu.bigbluebutton.org/bigbluebutton.asc -O- | sudo apt-key add - && \
    echo "deb http://ubuntu.bigbluebutton.org/trusty-1-0/ bigbluebutton-trusty main" | sudo tee /etc/apt/sources.list.d/bigbluebutton.list

#Add multiverse repo
RUN echo "deb http://us.archive.ubuntu.com/ubuntu/ trusty multiverse" | tee -a /etc/apt/sources.list

#Add LibreOffice 4.4 repo
RUN apt-add-repository ppa:libreoffice/libreoffice-4-4

#Install required packages
RUN apt-get -y update && apt-get install -y --allow-unauthenticated \
    bigbluebutton \
    bbb-demo \
    bbb-check \
    libreoffice-common \
    libreoffice \
    supervisor  \
    software-properties-common


#COPY ImageMagick Security policy updated

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80 443
CMD ["/usr/bin/supervisord"]
