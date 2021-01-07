FROM debian:bullseye

# need root for apt installs and make command
USER root

# Use noninteractive mode so apt knows we are running headless
ENV DEBIAN_FRONTEND=noninteractive
# Allow make arguments to be passed when running, e.g. -e MAKE_ARGS="clean"
ENV MAKE_ARGS=""

# Update the apt sources list to include deb-src sources
RUN echo "deb-src http://deb.debian.org/debian/ bullseye main" >> /etc/apt/sources.list
RUN echo "deb-src http://security.debian.org/debian-security bullseye-security main" >> /etc/apt/sources.list

# Install tools needed for netkit build
RUN apt update && apt install -yq apt-utils git make debootstrap libreadline-dev \
    init-system-helpers initscripts insserv bison flex gcc-multilib bc quilt xz-utils libvdeplug-dev

WORKDIR /netkit-build

# Make loop mounting work
RUN mknod /dev/loop0 b 7 0

COPY docker-start.sh /docker-start.sh
CMD /bin/bash -c "/docker-start.sh"
