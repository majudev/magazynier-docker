FROM debian:bullseye-slim

EXPOSE 80/tcp

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

COPY ./scripts /magazynier
COPY ./Magazynier-v0.1.1-ALPHA.zip /magazynier/Magazynier.zip
RUN mkdir /data

RUN /magazynier/init.sh

CMD /magazynier/start.sh
