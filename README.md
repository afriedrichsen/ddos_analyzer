# DDOS Analyzer Tool

A "Big Data" application for tracking potential DDOS threats.


Analyze log events for IP/host information and determine if that host is part of a DDOS attack, either ongoing or based on historical data.


### Overview

At its core, this analyzer tool runs on the Cloudera Hadoop stack. 

Data is harvested from log files/sources using a (scalable) Python script. 

Data is fed from the log files provided to the script to Apache Kafka. Apache Flume is used to further aggregate, index and filter the log messages sent by Kafka.

Oozie jobs execute the necessary SQL to load the messages into Hive tables where analysis is conducted to identify if the user's IP is part of a DDOS campaign.

### Prerequisites

The following tools are needed to run this demo/POC.
```
Docker (version 17.01 or greater)
docker-compose
```

### Installing


Clone the repo.

```
git clone https://github.com/afriedrichsen/ddos_analyzer
```

Build and Run

```
cd ddos_analyzer
docker-compose up --build -d
```

The initial build will take some time depending on your internet connection, but should only need to be done when starting the app initially. This is due to the size of the CDH Docker Image. An existing CDH instance can be used which cuts the deployment time significantly.

#### Swarm Mode

A slightly different compose file is provided to run the application from a Docker Host in "Swarm" mode.
```
docker stack deploy -c app-swarm.yml <ID>

e.g.

docker stack deploy -c app-swarm.yml app

```

## Deployment Notes

When running "Swarm" mode the Kafka service should be distributed one node per server (deploy: mode: global in Docker).

## Built With

* [Cloudera Docker Image](https://www.cloudera.com/documentation/enterprise/5-6-x/topics/quickstart_docker_container.html) - A single-node deployment of the Cloudera open-source distribution, including CDH and Cloudera Manager.
* [Apache Flume](https://flume.apache.org/) - Flume is a distributed, reliable, and available service for efficiently collecting, aggregating, and moving large amounts of log data. Used for aggregating/indexing log events before writing to Datalake/HDFS.
* [Apache Kafka](https://kafka.apache.org/) - Message system used to fetch and transmit logs from endpoints to Big Data infrastructure.

## Authors

* **Alex Friedrichsen** - *Initial work*


## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* [Inspiration - How Flume Met Kafka](http://blog.cloudera.com/blog/2014/11/flafka-apache-flume-meets-apache-kafka-for-event-processing/)
* [Log Analytics with Apache Kafka](https://blog.cloudera.com/blog/2015/02/how-to-do-real-time-log-analytics-with-apache-kafka-cloudera-search-and-hue/)
