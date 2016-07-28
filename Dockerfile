FROM php:7-fpm

MAINTAINER Dmitrii Zolotov <dzolotov@herzen.spb.ru>

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt upgrade -y && apt install -y git zlib1g-dev libmemcached-dev libmcrypt-dev libldap2-dev freetds-dev libjpeg-dev libpng-dev libfreetype6-dev libcurl4-gnutls-dev libxml2-dev libicu-dev libgmp3-dev libxslt1-dev wget
RUN ln -s /usr/include/ldap.h /usr/lib/x86_64-linux-gnu && \
    ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/ && \
    mkdir /root/sybase && mkdir /root/sybase/include && mkdir /root/sybase/lib && \
    ln -s /usr/include/syb*.h /root/sybase/include && \
    ln -s /usr/lib/x86_64-linux-gnu/libsyb* /root/sybase/lib && \
    docker-php-ext-configure pdo_dblib --with-pdo-dblib=/root/sybase && \
    docker-php-ext-configure ldap --with-ldap=/usr/lib/x86_64-linux-gnu && \
    docker-php-ext-configure mysqli --with-mysqli=mysqlnd && \
    docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    sed -i 's~;pid.*~pid=/run/php-fpm.pid~ig' /usr/local/etc/php-fpm.conf && \
    cd /root && git clone https://github.com/php-memcached-dev/php-memcached && cd php-memcached && git checkout php7 && phpize && ./configure --disable-memcached-sasl && make && make install && echo "extension=memcached.so" >>/usr/local/etc/php/conf.d/docker-php-ext-memcached.ini && rm -r /root/php-memcached && \
    cd /root && git clone https://github.com/phpredis/phpredis && cd phpredis && git checkout php7 && phpize && ./configure && make && make install && echo "extension=redis.so" >>/usr/local/etc/php/conf.d/docker-php-ext-redis.ini && rm -rf /root/phpredis && \
    echo "zend_extension=opcache.so" >/usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
    docker-php-ext-install -j4 iconv mcrypt ldap curl pdo_mysql mysqli soap intl gd gmp bcmath mbstring zip pcntl xsl && \
    ln -s /usr/local/bin/php /usr/bin/php && \
    mkdir /root/conf.d && cp -v /usr/local/etc/php/conf.d/* /root/conf.d/ && \
    cd /usr/bin && wget https://getcomposer.org/composer.phar && mv composer.phar composer && chmod +x composer && \
    wget http://gordalina.github.io/cachetool/downloads/cachetool.phar && mv cachetool.phar cachetool && chmod +x cachetool

#setup php-nginx binding
ADD fastcgi-php.conf /etc/nginx/snippets/fastcgi-php.conf
ADD startFPMWithDockerEnvs.sh /etc/php/7.0/startFPMWithDockerEnvs.sh
ADD php-production.ini /etc/php/7.0/
ADD php-development.ini /etc/php/7.0/
ADD 00-enable_modules /etc/container-run.d/
ADD 01-apply_environment /etc/container-run.d/

# Supervisor Config
ADD supervisord.conf /etc/supervisord.conf

#Attach volume to web-root
VOLUME ["/var/www/html/"]

ENV TIMEZONE GMT
ENV PHP_MODULES opcache phar json
ENV DEBUG false
ENV DEVUSER www-data

EXPOSE 9000

CMD ["supervisord","-n","-c","/etc/supervisord.conf"]
