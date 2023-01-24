FROM php:8.2-apache

ENV COMPOSER_ALLOW_SUPERUSER=1
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer --version

RUN apt-get update -qq && apt-get install -qy git gnupg unzip zip sudo
RUN docker-php-ext-install -j$(nproc) opcache pdo_mysql

COPY .deploy/php/php.ini /usr/local/etc/php/conf.d/app.ini
COPY .deploy/apache2/vhost.conf /etc/apache2/sites-available/000-default.conf
COPY .deploy/apache2/apache.conf /etc/apache2/conf-available/z-app.conf
COPY .deploy/index.php /var/www/html/public/index.php

RUN a2enconf z-app

RUN chown -R www-data:www-data /var/www/html

RUN  useradd -u 1000 debian && echo "debian:debian" | chpasswd && adduser debian sudo

EXPOSE 80

USER debian

WORKDIR /var/www/html