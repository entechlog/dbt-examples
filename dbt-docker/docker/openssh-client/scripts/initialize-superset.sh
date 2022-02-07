#!/bin/sh
#
cd /usr/src/
#
echo "===> Create superset user"
docker exec --tty -it apache-superset superset fab create-admin --username $SUPERSET_USER --firstname Superset --lastname Admin --email admin@superset.com --password $SUPERSET_PASSWORD
#
echo "===> Migrate superset local DB to latest"
sleep 1
docker exec --tty -it apache-superset superset db upgrade
#
echo "===> Setup superset roles"
sleep 1
docker exec --tty -it apache-superset superset init
#