FROM ubuntu:14.04
MAINTAINER Fabio Nitto <fabio.nitto@gmail.com>

RUN apt-get update && apt-get install -y supervisor

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
