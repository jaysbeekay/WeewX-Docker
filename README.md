# UPDATE TO 4.5.1

With this, you'll get:
- WeewX 4.5.1 installed from sources, with:
- The Interceptor driver (https://github.com/matthewwall/weewx-interceptor)
- The MQTT Publish service (https://github.com/weewx/weewx/wiki/mqtt)
- Installed in a docker image based from Debian:buster
- weewx-core will expose port 8090 to listen for Weather Station Clients
- weewx-web will listen on port 8080 in the regular network driver and will expose the weather in a nice nginx web page

I provide with a docker-compose, running two services:
- weewx-core (the weewx install)
- weewx-web (an nginx web-server)

You'll probably want to mount some files/directories inside the container to keep data, so adapt the docker-compose to your needs:
- <some directory>/weewx.conf:/home/weewx/weewx.conf
- <some directory>/html/:/home/weewx/public_html/
- <some directory>/archive:/home/weewx/archive/

How to use:
- First, git clone this repo:
git clone https://github.com/MrNonoss/weewx.git
- Change directory and create the image:
cd .. && docker build -t weewx .
- Then, rename the docker-compose and run it:
docker-compose up
