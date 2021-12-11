#!/bin/bash
cd "$(dirname "$0")"

echo "Working in `pwd`"

./configure.sh
if [ ! $? -eq 0 ]; then
	echo "Couldn't configure the system. Exiting."
	exit -1
fi

. /data/config.sh

echo "START_NGINX=$START_NGINX"
echo "START_POSTFIX=$START_POSTFIX"
echo "START_REDIS=$START_REDIS"
echo "START_MYSQL=$START_MYSQL"

if [[ "$START_NGINX" == "yes" ]]; then
	service nginx start
else
	service nginx stop
fi
if [[ "$START_POSTFIX" == "yes" ]]; then
	service postfix start
else
	service postfix stop
fi
if [[ "$START_REDIS" == "yes" ]]; then
	service redis-server start
else
	service redis-server stop
fi
if [[ "$START_MYSQL" == "yes" ]]; then
	service mariadb start
else
	service mariadb stop
fi

_term() {
	echo "Caught SIGTERM signal!"
	kill -s KILL "$child"
	
	service mariadb stop
	service redis-server stop
	service nginx stop
	service postfix stop
}
trap _term SIGTERM

echo "Starting Magazynier.jar"
java -jar Magazynier.jar \
	--spring.datasource.url=$MYSQL_HOST \
	--spring.datasource.username=$MYSQL_USER \
	--spring.datasource.password=$MYSQL_PASSWORD \
	--smtp.host=$MAIL_SERVER \
	--smtp.port=$MAIL_PORT \
	--smtp.user=$MAIL_USER \
	--smtp.password=$MAIL_PASSWORD \
	--smtp.transport=$MAIL_TRANSPORT \
	--smtp.from="$MAIL_FROM" \
	--smtp.baseurl="$SITE_BASEURL" \
	&

child=$!
wait "$child"
