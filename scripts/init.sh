#!/bin/bash
cd "$(dirname "$0")"

unzip Magazynier.zip
./init-mysql.sh
./init-exim4.sh
./init-nginx.sh
