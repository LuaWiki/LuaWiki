#!/bin/bash
DB_NAME=${1:`echo mywiki`}
mariadbd --user=root 1> /dev/null &
sleep 5
mysql -u root $DB_NAME < /opt/luawiki/sql/zhwiki.sql
exit 0