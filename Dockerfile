#FROM debian:stretch-slim
FROM debain:bookworm-slim

#############################
# Install Required Packages #
#############################

RUN apt-get update && apt-get install -y \
    curl \
    ftp \
    gnupg \
    lsb-base \
    mysql-client \
    python3 \
    #python3-cheetah \
    python3-configobj \
    python3-dev \
    python-imaging \
    python3-pil \
    python3-serial \
    python3-usb \
    python3-pip \
    #python3-cheetah \
    python3-ephem \
    python3-mysqldb \
    procps \
    wget \
    rsyslog \
    rsync \
&& rm -rf /var/lib/apt/lists/*

RUN pip3 install Cheetah3
RUN pip3 install paho-mqtt

#################
# Install WeewX #
#################

RUN cd /tmp && wget http://weewx.com/downloads/weewx-5.0.2.tar.gz && tar xvfz weewx-5.0.2.tar.gz && cd weewx-5.0.2 && python3 ./setup.py build && python3 ./setup.py install --no-prompt

###################################
# Download and Install Extentions #
###################################

RUN cd /tmp && wget -O weewx-interceptor.zip https://github.com/matthewwall/weewx-interceptor/archive/master.zip && wget -O weewx-neowx.zip https://projects.neoground.com/neowx/download/latest && wget -O weewx-mqtt.zip https://github.com/matthewwall/weewx-mqtt/archive/master.zip

RUN cd /tmp && /usr/sbin/rsyslogd && /home/weewx/bin/wee_extension --install weewx-interceptor.zip && /home/weewx/bin/wee_extension --install weewx-neowx.zip && /home/weewx/bin/wee_extension --install weewx-mqtt.zip && /home/weewx/bin/wee_config --reconfigure --driver=user.interceptor --no-prompt

#RUN cd /tmp && /home/weewx/bin/wee_extension --install weewx-interceptor.zip && /home/weewx/bin/wee_extension --install weewx-neowx.zip && /home/weewx/bin/wee_extension --install weewx-mqtt.zip && /home/weewx/bin/wee_config --reconfigure --driver=user.interceptor --no-prompt


###################################
# Download and Install Extentions #
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

#RUN cd /home/weewx
#RUN cp /home/weewx/util/init.d/weewx.debian /etc/init.d/weewx
#RUN chmod +x /etc/init.d/weewx
#RUN update-rc.d weewx defaults 98
#CMD /etc/init.d/weewx start
