FROM hypriot/rpi-alpine-scratch
MAINTAINER Óscar de Arriba <odarriba@gmail.com>

##################
##   BUILDING   ##
##################

# Versions to use
ENV netatalk_version 3.1.8

WORKDIR /

# Prerequisites
RUN apk update && \
    apk upgrade && \
    apk add \
      bash \
      avahi \
      libldap \
      libgcrypt \
      python \
      dbus \
      dbus-glib \
      py-dbus \
      linux-pam \
      cracklib \
      db \
      libevent \
      file \
      acl \
      openssl && \
    apk add --virtual .build-deps \
      build-base \
      autoconf \
      automake \
      libtool \
      avahi-dev \
      libgcrypt-dev \
      linux-pam-dev \
      cracklib-dev \
      acl-dev \
      db-dev \
      dbus-dev \
      libevent-dev && \
    ln -s -f /bin/true /usr/bin/chfn && \
    cd /tmp && \
    wget http://prdownloads.sourceforge.net/netatalk/netatalk-${netatalk_version}.tar.gz && \
    tar xvf netatalk-${netatalk_version}.tar.gz && \
    cd netatalk-${netatalk_version} && \
    CFLAGS="-Wno-unused-result -O2" ./configure \
      --prefix=/usr \
      --localstatedir=/var/state \
      --sysconfdir=/etc \
      --with-dbus-sysconf-dir=/etc/dbus-1/system.d/ \
      --sbindir=/usr/bin \
      --enable-quota \
      --with-tdb \
      --enable-silent-rules \
      --with-cracklib \
      --with-cnid-cdb-backend \
      --enable-pgp-uam \
      --with-acls && \
    make && \
    make install && \
    cd /tmp && \
    rm -rf netatalk-${netatalk_version} netatalk-${netatalk_version}.tar.gz && \
    apk del .build-deps && \
		rm -rf /var/cache/apk/*

RUN  mkdir -p /timemachine

# Create the log file
RUN touch /var/log/afpd.log

ADD entrypoint.sh /entrypoint.sh
ADD bin/add-account /usr/bin/add-account

EXPOSE 548 636

VOLUME ["/timemachine"]

CMD ["/bin/bash", "/entrypoint.sh"]
