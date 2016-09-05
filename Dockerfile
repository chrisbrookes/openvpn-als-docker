FROM openjdk:8
MAINTAINER Chris Brookes <cbrookes@retailexpress.com>

RUN apt-get update \
    && apt-get install -y curl wget unzip git ant \
    && rm -rf /var/lib/apt/lists/*

ENV OPENVPNALS_HOME=/opt/openvpn-als
ENV OPENVPNALS_APPS_HOME=/opt/openvpn-als-applications

ARG OPENVPNALS_GIT_REPO
ARG OPENVPNALS_APPS_GIT_REPO
ENV OPENVPNALS_GIT_REPO ${OPENVPNALS_GIT_REPO:-https://github.com/chrisbrookes/openvpn-als.git}
ENV OPENVPNALS_APPS_GIT_REPO ${OPENVPNALS_APPS_GIT_REPO:-https://github.com/chrisbrookes/openvpn-als-applications.git}

RUN mkdir $OPENVPNALS_HOME && mkdir $OPENVPNALS_APPS_HOME

# Get the main src
WORKDIR $OPENVPNALS_HOME

RUN git clone $OPENVPNALS_GIT_REPO .

# Compile
RUN ant compile
RUN ant install-agent

# Get the extension applications
WORKDIR $OPENVPNALS_APPS_HOME
RUN git clone $OPENVPNALS_APPS_GIT_REPO .

# The extensions src already has built zips, so just copy what we need to main src extensions archives dir
# This installs ALL the extensions
RUN mkdir -p /opt/openvpn-als/adito/conf/repository/archives
RUN for line in $(find . -iname 'adito-application*.zip'); do \
        echo "Copying: $line"; \
        cp "$line" $OPENVPNALS_HOME/adito/conf/repository/archives/ ; \
    done

# build & install the ldap extension
WORKDIR $OPENVPNALS_HOME/adito-community-ldap
RUN ant install

WORKDIR $OPENVPNALS_HOME

EXPOSE 28080 443

VOLUME $OPENVPNALS_HOME/adito/conf

# If these were available, these could be added to the image.
#ADD keystore.jks /opt/openvpn-als/adito/conf/repository/keystore/default.keystore.jks
#ADD webserver.properties /opt/openvpn-als/adito/conf/

# Default command, just tail so we can exec bash
CMD tail -f /dev/null