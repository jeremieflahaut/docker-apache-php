#!/usr/bin/env bash

echo "Run startup.sh ..."

echo "Host UID (startup): $USER_ID"
echo "Host GID (startup): $GROUP_ID"


LASTLINE=""

RUNAS="sudo -u root bash"

while IFS= read -r line;
do
  echo $line
  LASTLINE=$line
  done < <($RUNAS <<_

usermod -u $USER_ID debian
groupmod -g $GROUP_ID debian
chown -R $USER_ID:$GROUP_ID /home/debian
chown -R $USER_ID:$GROUP_ID /var/spool/cron/crontabs/debian

# Start the cron service in the background. Unfortunately upstart doesnt work yet.
echo "Run cron..."
cron

#Start PHP-FPM
echo "Start PHP-FPM..."
sed -i "s/www-data/debian/g" /etc/php/8.2/fpm/pool.d/www.conf
sed -i "s/;clear_env/clear_env/g" /etc/php/8.2/fpm/pool.d/www.conf
service php8.2-fpm start

#Start nginx
echo "start apache2 ..."
sed -i "s/www-data/debian/g" /etc/apache2/envvars
apachectl -D FOREGROUND

_
)

if ! [[ "$((${LASTLINE: -1}))" =~ ^[0-9]+$ ]]
    then
        exit 0
fi

exit $((${LASTLINE: -1}))
