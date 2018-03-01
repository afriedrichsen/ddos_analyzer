FROM python:3.6

MAINTAINER Alex Friedrichsen afriedrichsen@me.com

WORKDIR /app

ADD . /app

RUN pip install --trusted-host pypi.python.org -r requirements.txt

ENV ENV PRODUCTION

CMD ["python","logHarvest.py","watchDir","./data/input"]

