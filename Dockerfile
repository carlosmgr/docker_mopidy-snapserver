FROM debian:stretch-slim

# Mopidy installation 
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y curl dumb-init gnupg python-crypto
RUN curl -L https://apt.mopidy.com/mopidy.gpg | apt-key add
RUN curl -L https://apt.mopidy.com/mopidy.list -o /etc/apt/sources.list.d/mopidy.list
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mopidy

# Snapserver installation
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y wget avahi-daemon avahi-utils supervisor
RUN  wget https://github.com/badaix/snapcast/releases/download/v0.15.0/snapserver_0.15.0_amd64.deb -P /var/tmp/
RUN dpkg -i --force-all /var/tmp/snapserver_0.15.0_amd64.deb
RUN apt-get -f install -y

# Clean-up
RUN apt-get purge --auto-remove -y curl wget 
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache

# Default configuration.
RUN mkdir -p /usr/home/.config/snapserver/
ENV HOME=/usr/home/
RUN mv /etc/default/snapserver /usr/home/.config/snapserver/snapserver
RUN ln -sf /usr/home/.config/snapserver/snapserver /etc/default/snapserver
ADD ./supervisord.conf /etc/supervisord.conf
ADD ./start.sh /start.sh
RUN chmod a+x /start.sh

# Config directory
VOLUME /usr/home
# Mopidy Media directory
VOLUME /var/lib/mopidy/media

# mopidy mpd Port
EXPOSE 6600
# mopidy http Port
EXPOSE 6680
# mDNS
EXPOSE 5353
# snapserver Ports
EXPOSE 1704
EXPOSE 1705

# Start
ENTRYPOINT ["/start.sh"]
