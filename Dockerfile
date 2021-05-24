#-------------------------------------------------------
# Dockerfile for building Weewx system
# With the interceptor driver and the neowx skin
#
#---> git clone the repo
#-->> build via 'docker build -t weewx .'
#->>> modify the docker-compose.yml to your needs
#>>>> run via 'docker-compose up
#
# last modified:
#     2019-05-20 - First Commit
#     2019-06-08 - Manage logs
#     2019-11-03 - Change install with source and update to 3.9.2
#	  2019-11-08 - Add docker compose with nginx and custom macvlan
#	  2020-11-06 - Update to 4.2.0
#   2021-05-24 - Update to 4.5.1 and python3
#-------------------------------------------------------
FROM debian:buster-slim
MAINTAINER Jonathan KAISER "jonathanbkaiser [@] gmail.com"

#############################
# Install Required Packages #
#############################

RUN apt-get update && apt-get full-upgrade -y \
    && apt-get install \
    apt-utils \
    python \
    python3-pil \
    python-imaging \
    python3-cheetah \
    python3-configobj \
    python3-ephem
    python3-pip \
    python-cheetah \
    mysql-client \
    python-mysqldb \
    ftp \
    python3-dev \
    python3-pip \
    curl \
    wget \
    rsyslog \
    rsync \
    procps \
    gnupg -y && pip install pyephem

#################
# Install WeewX #
#################

RUN cd /tmp && wget http://weewx.com/downloads/weewx-4.5.1.tar.gz && tar xvfz weewx-4.5.1.tar.gz && cd weewx-4.5.1 && python3 ./setup.py build && python3 ./setup.py install --no-prompt

###################################
# Download and Install Extensions #
###################################

RUN cd /tmp

RUN wget -O weewx-interceptor.zip https://github.com/matthewwall/weewx-interceptor/archive/master.zip
RUN wget -O weewx-mqtt.zip https://github.com/matthewwall/weewx-mqtt/archive/master.zip

RUN /usr/sbin/rsyslogd && /home/weewx/bin/wee_extension --install weewx-interceptor.zip && /home/weewx/bin/wee_extension --install weewx-mqtt.zip && /home/weewx/bin/wee_config --reconfigure --driver=user.interceptor --no-prompt

###################################
#   Download and Install Skins    #
###################################

#ADD ${PWD}/src/skin.conf /home/weewx/skins/neowx/skin.conf
#ADD ${PWD}/src/daily.json.tmpl /home/weewx/skins/neowx/daily.json.tmpl

#################
# Execute Weewx #
#################

ADD ${PWD}/src/start.sh /
RUN chmod +x /start.sh
CMD ["/start.sh"]
