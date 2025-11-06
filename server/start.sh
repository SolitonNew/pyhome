#!/bin/sh -e

export LANG=en_US.utf8

cd /var/www/pyhome/server/manager
python3 /var/www/pyhome/server/manager/manager_demon.py

exit 0
