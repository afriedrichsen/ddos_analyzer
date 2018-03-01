from kafka import KafkaProducer
from kafka.errors import KafkaError
import os
import sys

def worker(inputDir):
    producer = KafkaProducer(bootstrap_servers=['kafka:9092'])
    # Asynchronous by default
    for row in file:
        producer.send('LogProcessing', row.encode())

    # block until all async messages are sent
    producer.flush()

    # configure multiple retries
    #producer = KafkaProducer(retries=5)

################################### Main ################################
if __name__ == "__main__":
    pInputDir = sys.argv[1]
    worker(pInputDir)