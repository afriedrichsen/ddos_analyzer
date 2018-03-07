"""

Log File aggregator script.


by. Alex Friedrichsen

2/26/18


Processes log files (e.g. webserver access log files) and writes rows to Apache Kafka.


Script can be run to either watch (tail) a single file or an entire directory of log files.



"""

from kafka import KafkaProducer
from kafka.errors import KafkaError
import time
import subprocess
import select
import shutil
import sys
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler


# Function that writes data to Kafka (producer).
def write_message(message):
    print(message)
    # Here is our connection to Kafka.
    # In prod, this setting is derived from ConfigParser object.
    producer = KafkaProducer(bootstrap_servers=['kafka:9092'])
    future = producer.send('LogProcessing', message)
    try:
        record_metadata = future.get(timeout=10)
    except KafkaError:
        pass

# Function that tails individual file and returns rows to Kafka message service.
def watch_file(inputFile):

    f = subprocess.Popen(['tail','-F',inputFile], stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    p = select.poll()
    p.register(f.stdout)

    while True:
        if p.poll(1):
            #print(f.stdout.readline())
            row = f.stdout.readline()
            write_message(row)
        time.sleep(1)

    # block until all async messages are sent
    #producer.flush()

# Function that allows us to watch a directory
def watch_directory(inputDir):

    print("Harvester is running is watching directory " + inputDir + " for new files...")

    path = inputDir if len(inputDir) > 1 else '.'

    event_handler = Handler()

    observer = Observer()

    observer.schedule(event_handler, path, recursive=True)

    #Start the file watcher.
    observer.start()
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()

    observer.join()

# Filesystem Handler class. Used by our file watcher function written above.
class Handler(FileSystemEventHandler):

    @staticmethod
    def on_any_event(event):
        #processed = './data/processed'

        if event.is_directory:
            return None

        elif event.event_type == 'created':
        # Take any action here when a file is first created.
            targetFile = str(event.src_path)
            print("File "+ targetFile + " created/loaded into directory...")
            for row in open(targetFile,'r'):
                #Write to Kafka.
                print(row)
                write_message(row.encode())
            # Move log file to "processed" directory.
            shutil.move(targetFile, './data/processed/')


# Main worker function that determines how producer should run.
def worker(inputProcessType, inputData):
    if inputProcessType=="watchFile":
        watch_file(inputData)
    elif inputProcessType == "watchDir":
        watch_directory(inputData)
    else:
        print("Invalid data source parameter!")



################################### Main ################################
if __name__ == "__main__":
    pProcessType = sys.argv[1]
    pInputData = sys.argv[2]

    #Run program with provided arguments.
    worker(pProcessType, pInputData)