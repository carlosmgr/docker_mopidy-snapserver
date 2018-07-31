FROM debian:stretch-slim

# Install
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y curl dumb-init gnupg python-crypto
RUN curl -L https://apt.mopidy.com/mopidy.gpg | apt-key add
RUN curl -L https://apt.mopidy.com/mopidy.list -o /etc/apt/sources.list.d/mopidy.list
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mopidy

# Clean-up
RUN apt-get purge --auto-remove -y curl
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache

# Default configuration.
COPY mopidy.conf /var/lib/mopidy/.config/mopidy/mopidy.conf
ENV HOME=/var/lib/mopidy

# mopidy user
#USER mopidy

# Home directory
VOLUME /var/lib/mopidy/
# Media directory
VOLUME /var/lib/mopidy/media

# Port mpd
EXPOSE 6600
# Port http
EXPOSE 6680

ENTRYPOINT ["/usr/bin/dumb-init"]
# Start mopidy
CMD ["/usr/bin/mopidy"]
