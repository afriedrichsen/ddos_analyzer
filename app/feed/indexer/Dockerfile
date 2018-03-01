FROM anapsix/alpine-java:latest

ARG flume_version=1.8.0
ARG flume_agent_name=log_analyzer

MAINTAINER Alex Friedrichsen afriedrichsen@me.com

ENV FLUME_VERSION=$flume_version \
    JAVA_HOME=/opt/java \
    PATH=/opt/flume/bin:/opt/java/bin:$PATH \
    FLUME_AGENT_NAME=$flume_agent_name

RUN apk add --update unzip wget curl jq coreutils \
    && mkdir -p /opt/flume/logs \
    && touch /opt/flume/logs/flume.log \
    && wget -qO- http://archive.apache.org/dist/flume/${FLUME_VERSION}/apache-flume-${FLUME_VERSION}-bin.tar.gz \
          | tar zxvf - -C /opt/flume --strip 1

ADD ../start-flume.sh /opt/flume/bin/start-flume

ADD flume-tail.conf /opt/flume/conf/flume.conf

RUN chown daemon -Rf /opt

# Let's be super secure (even though this Docker) and run this as a standard user.
USER daemon

WORKDIR /opt/flume

ENTRYPOINT ["start-flume"]