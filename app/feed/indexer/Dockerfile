FROM anapsix/alpine-java:latest

ARG flume_version=1.8.0
ARG flume_agent_name=indexer1

MAINTAINER Alex Friedrichsen afriedrichsen@me.com

ENV FLUME_VERSION=$flume_version \
    #JAVA_HOME=/opt/jdk \
    PATH=/opt/flume/bin:$PATH \
    FLUME_AGENT_NAME=$flume_agent_name

RUN apk add --update unzip wget jq coreutils \
    && mkdir -p /opt/flume/logs \
    && mkdir -p /opt/flume/conf \
    && mkdir -p /opt/hadoop \
    && touch /opt/flume/logs/flume.log \
    && wget -qO- http://archive.apache.org/dist/flume/${FLUME_VERSION}/apache-flume-${FLUME_VERSION}-bin.tar.gz \
          | tar zxvf - -C /opt/flume --strip 1 \
    && wget -qO- http://mirrors.sonic.net/apache/hadoop/common/hadoop-3.0.0/hadoop-3.0.0.tar.gz \
          | tar zxvf - -C /opt/hadoop --strip 1
RUN which java
ADD hadoop-env.sh /opt/hadoop

ADD start-flume-docker.sh /opt/flume/bin/start-flume-docker
ADD start-flume.sh /opt/flume/bin/start-flume
ADD flume-env.sh /opt/flume/conf/flume-env.sh
ADD flume.conf /opt/flume/conf/flume.conf

#RUN chown daemon -Rf /opt

# Let's be super secure (even though this Docker) and run this as a standard user.
#USER daemon

WORKDIR /opt/flume

ENTRYPOINT ["start-flume-docker"]
