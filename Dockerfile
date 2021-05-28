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
#   2021-05-24 - Update to 4.5.1 and python3
#-------------------------------------------------------

FROM debian:buster-slim

#############################
#    Setup ENV Variables    #
#############################

ENV HOME=/home/weewx
ENV TZ=Australia/Perth

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#############################
# Install Required Packages #
#############################

RUN apt-get update && apt-get install -y \
    apt-utils \
    curl \
    ftp \
    gnupg \
    lsb-base \
    #mysql-client \
    python3 \
    python3-configobj \
    python3-dev \
    #python-imaging \
    python3-pil \
    python3-serial \
    python3-usb \
    python3-pip \
    python3-ephem \
    python3-mysqldb \
    procps \
    wget \
    rsyslog \
    rsync \
&& rm -rf /var/lib/apt/lists/*

RUN pip3 install Cheetah3
RUN pip3 install paho-mqtt

RUN mkdir /var/log/weewx
RUN mkdir /home/weewx/tmp
RUN mkdir /home/weewx/public_html

# Fixes RSYSLOG error in docker logs
RUN sed -i '/imklog/s/^/#/' /etc/rsyslog.conf

#################
# Install WeewX #
#################

RUN cd /tmp && wget http://weewx.com/downloads/weewx-4.5.1.tar.gz && tar xvfz weewx-4.5.1.tar.gz && cd weewx-4.5.1 && python3 ./setup.py build && python3 ./setup.py install --no-prompt

###################################
# Download and Install Extensions #
###################################

RUN cd /tmp && wget -O weewx-interceptor.zip https://github.com/matthewwall/weewx-interceptor/archive/master.zip && wget -O weewx-mqtt.zip https://github.com/matthewwall/weewx-mqtt/archive/master.zip && wget -O weewx-owm.zip https://github.com/matthewwall/weewx-owm/archive/master.zip
RUN cd /tmp && /usr/sbin/rsyslogd && /home/weewx/bin/wee_extension --install weewx-interceptor.zip && /home/weewx/bin/wee_extension --install weewx-mqtt.zip && /home/weewx/bin/wee_extension --install weewx-owm.zip && /home/weewx/bin/wee_config --reconfigure --driver=user.interceptor --no-prompt

# Fixes error with interceptor and invalid key
ADD ${PWD}/src/interceptor.py /home/weewx/bin/interceptor.py

###################################
#   Download and Install Skins    #
###################################

#ADD ${PWD}/src/skin.conf /home/weewx/skins/neowx/skin.conf
#ADD ${PWD}/src/daily.json.tmpl /home/weewx/skins/neowx/daily.json.tmpl

######################
# Expose Weewx Ports #
######################

EXPOSE 8090/tcp

#################
# Execute Weewx #
#################

ADD ${PWD}/src/start.sh /
RUN chmod +x /start.sh
CMD ["/start.sh"]
