#!/bin/bash
echo "Updating exim4 config"
sed -i "s/dc_eximconfig_configtype='local'/dc_eximconfig_configtype='internet'/g" /etc/exim4/update-exim4.conf.conf
service exim4 restart
