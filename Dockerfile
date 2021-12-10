FROM debian:bullseye-slim

RUN apt-get update && \
    apt-get upgrade && \
    apt-get install -y \
    mariadb-server-10.5 \
    mariadb-client-10.5 \
    openjdk-11-jre \
    nginx-light \
    redis-server \
    exim4

RUN apt-get install -y \
    wget unzip

COPY ./scripts /scripts
