#!/bin/bash
cd "$(dirname "$0")"

unzip Magazynier.zip
./init-mysql.sh
./init-nginx.sh
