#!/bin/bash
cd "$(dirname "$0")"

echo "Working in `pwd`"

if [ ! -d /data ]; then
	echo "Creating /data"
	mkdir /data
fi

echo "Loading config"
# Init config
if [ ! -e /data/version ]; then
	echo "No config found, creating one"
	echo "Creating version file"
	./version.sh > /data/version

	if [ ! -e /data/config.sh ]; then
		echo "Creating config.sh"
		tee /data/config.sh << EOF
MYSQL_HOST="jdbc:mariadb://localhost:3306/magazynier"
MYSQL_USER="magazynier"
MYSQL_PASSWORD="`echo $RANDOM | md5sum | head -c 25`"
MAIL_SERVER="localhost"
MAIL_PORT="25"
MAIL_USER=""
MAIL_PASSWORD=""
MAIL_TRANSPORT="SMTP"
MAIL_FROM="no-reply@localhost"
SITE_BASEURL="http://localhost/magazynier"
SITE_APIURL="http://localhost/api"

START_MYSQL=yes
START_POSTFIX=yes
START_REDIS=yes
START_NGINX=yes
EOF
	fi
	. /data/config.sh
	
	echo "Move MySQL data directory"
	service mariadb stop
	cp -r /var/lib/mysql /data/mysql
	chown -R mysql:mysql /data/mysql
	sed -E -i 's_/var/lib/mysql_/data/mysql_g' /etc/mysql/mariadb.conf.d/50-server.cnf
	service mariadb start
	
	echo "Creating database & user"
	MYSQL_DATABASE="${MYSQL_HOST##*/}"
	mysql << EOF
		CREATE DATABASE $MYSQL_DATABASE;
		CREATE USER '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';
		GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'localhost';
		FLUSH PRIVILEGES;
EOF
	echo "Creating database schema..."
	cat schema.sql | sed 's/InnoDB/InnoDB;/g' | sed 's/increment by 1/increment by 1;/g' | sed -E 's/(unique \(.+\))/\1;/g' | sed -E 's/(references .+ \(.+\))/\1;/g' > schema.mariadb
	mysql -D $MYSQL_DATABASE --user=$MYSQL_USER --password=$MYSQL_PASSWORD < schema.mariadb
fi

CURRENT_VERSION="`./version.sh`"
VERSION="`cat /data/version`"

if ! [[ "$VERSION" == "$CURRENT_VERSION" ]]; then
	echo "Your docker container version doesn't match config version"
	exit -1
fi

. /data/config.sh

# Check required config variables
if [[ "$SITE_BASEURL" == "" ]] || [[ "$SITE_APIURL" == "" ]]; then
	echo "SITE_APIURL or SITE_BASEURL not set!"
	exit -1
fi


# Actual config update
echo "Updating frontend config"
sed -E -i 's_(var baseUrl = ").+(";)_\1'$SITE_BASEURL'\2_g' /var/www/html/magazynier/js/config.js
sed -E -i 's_(var apiUrl = ").+(";)_\1'$SITE_APIURL'\2_g' /var/www/html/magazynier/js/config.js

echo "Updating MySQL data directory"
service mariadb stop
sed -E -i 's_/var/lib/mysql_/data/mysql_g' /etc/mysql/mariadb.conf.d/50-server.cnf
service mariadb start
