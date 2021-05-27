#!/usr/bin/env bash

HOME=/home/weewx
echo "Using Default CONF"

# # TODO - check for existence of conf dir - exit(1) if not found

# cp -rv $HOME/conf/$CONF/* /home/weewx/

CONF_FILE=$HOME/weewx.conf

#/usr/sbin/rsyslogd
#/home/weewx/bin/weewxd /home/weewx/weewx.conf

cd $HOME

./bin/weewxd $CONF_FILE > /dev/stdout
