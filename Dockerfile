FROM debian:bullseye-slim

EXPOSE 80/tcp

SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    apt-get upgrade && \
    apt-get install -y \
    mariadb-server-10.5 \
    mariadb-client-10.5 \
    openjdk-11-jre \
    nginx-light \
    redis-server

RUN debconf-set-selections <<< "postfix postfix/mailname string example.com"
RUN debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
RUN apt-get install -y \
    postfix

RUN apt-get install -y \
    wget unzip

COPY ./scripts /magazynier
COPY ./Magazynier-v0.1.3-ALPHA.zip /magazynier/Magazynier.zip
RUN mkdir /data

RUN /magazynier/init.sh

CMD ["/magazynier/start.sh"]
