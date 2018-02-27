# DDOS Analyzer Tool

A "Big Data" application for tracking potential DDOS threats.

### Prerequisites

The following tools are needed to run this demo/POC.
```
Docker (version )
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

The initial build will take some time depending on your internet connection, but should only need to be done when starting the app initially.

####Swarm Mode

A slightly different compose file is provided to run the above application from a Docker Swarm.
```
docker stack deploy -c app-swarm.yml <ID>

e.g.

docker stack deploy -c app-swarm.yml app

```

## Deployment

Add additional notes about how to deploy this on a live system

## Built With

* [Cloudera Docker Image](https://www.cloudera.com/documentation/enterprise/5-6-x/topics/quickstart_docker_container.html) - A single-node deployment of the Cloudera open-source distribution, including CDH and Cloudera Manager.
* [Apache Flume](https://flume.apache.org/) - Flume is a distributed, reliable, and available service for efficiently collecting, aggregating, and moving large amounts of log data. Used for aggregating/indexing log events before writing to Datalake/HDFS.
* [Apache Kafka](https://kafka.apache.org/) - Message system used to fetch and transmit logs from endpoints to Big Data infrastructure.

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Authors

* **Alex Friedrichsen** - *Initial work*


## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* [Inspiration]()
* etc
