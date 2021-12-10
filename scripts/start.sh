#!/bin/bash
cd "$(dirname "$0")"

echo "Working in `pwd`"

service nginx start
service exim4 start
service redis-server start
service mariadb start

./configure.sh
if [ ! $? -eq 0 ]; then
	echo "Couldn't configure the system. Exiting."
	exit -1
fi

. /data/config.sh

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
	--smtp.baseurl="$SITE_BASEURL"
