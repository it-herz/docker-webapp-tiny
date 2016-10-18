FROM php:7-fpm-alpine

ADD php-fpm /etc/init.d

#install all packages
RUN	sed -i -e 's/v3\.2/edge/g' /etc/apk/repositories && \
        apk update && apk upgrade && \
        apk add wget bash autoconf \
	file \
	g++ \
	gcc \
	openrc \
	musl-dev \
	curl-dev \
	curl \
	gnupg \
	libedit-dev \
        libedit \
	libxml2-dev \
        libxml2 \
	openssl-dev \
        openssl \
        jpeg-dev \
        jpeg \
	git \
        libmcrypt-dev \
        libmcrypt \
        gmp-dev \
        gmp \
        icu icu-dev icu-libs \
        libxslt-dev \
        libxslt \
	libpng-dev \
        libpng \
        mariadb-dev \
        mariadb-libs \
	sqlite-dev \
        sqlite \
	libmemcached-dev \
	libmemcached-libs \
	freetype-dev \
        freetype \
        openldap-dev \
        libldap \
	make \
	pkgconf \
	re2c && \
    sed -i 's/#rc_sys=""/rc_sys="lxc"/g' /etc/rc.conf && \
    echo 'rc_provide="loopback net"' >> /etc/rc.conf && \
    sed -i 's/^#\(rc_logger="YES"\)$/\1/' /etc/rc.conf && \
    docker-php-ext-configure ldap && \
    docker-php-ext-configure mysqli --with-mysqli=mysqlnd && \
    docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    chmod +x /etc/init.d/php-fpm && \
    sed -i 's~;pid.*~pid=/run/php-fpm.pid~ig' /usr/local/etc/php-fpm.conf && \
    rc-update add php-fpm sysinit && mkdir -p /run/openrc && touch /run/openrc/softlevel && \
    rc-update add local sysinit && \
    echo "/sbin/rc" >> /root/rc && chmod +x /root/rc && \
    cd /root && git clone https://github.com/php-memcached-dev/php-memcached && cd php-memcached && git checkout php7 && phpize && ./configure --disable-memcached-sasl && make && make install && echo "extension=memcached.so" >>/usr/local/etc/php/conf.d/docker-php-ext-memcached.ini && rm -r /root/php-memcached && \
    cd /root && git clone https://github.com/phpredis/phpredis && cd phpredis && git checkout php7 && phpize && ./configure && make && make install && echo "extension=redis.so" >>/usr/local/etc/php/conf.d/docker-php-ext-redis.ini && rm -rf /root/phpredis && \
    echo "zend_extension=opcache.so" >/usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
    cd /root && git clone https://github.com/mongodb/mongo-php-driver.git && cd mongo-php-driver && git submodule sync && git submodule update --init && phpize && ./configure && make all -j 5 && sudo make install && rm -r /root/mongo-php-driver && echo "extension=mongodb.so" > /usr/local/etc/php/conf.d/docker-php-ext-mongodb.ini && \
    docker-php-ext-install -j4 iconv mcrypt ldap curl pdo_mysql mysqli soap intl gd gmp bcmath mbstring zip pcntl xsl && \
    ln -s /usr/local/bin/php /usr/bin/php && \
    mkdir /root/conf.d && cp -v /usr/local/etc/php/conf.d/* /root/conf.d/ && \
    cd /usr/bin && wget https://getcomposer.org/composer.phar && mv composer.phar composer && chmod +x composer && \
    wget http://gordalina.github.io/cachetool/downloads/cachetool.phar && mv cachetool.phar cachetool && chmod +x cachetool && \
    apk del curl-dev openldap-dev freetype-dev libmemcached-dev sqlite-dev libxslt-dev gmp-dev openssl-dev curl-dev libxml2-dev libedit-dev && \
    sed -i  's/;pm.status_path = \/status/pm.status_path = \/status/' /usr/local/etc//php-fpm.d/www.conf && umask 002 && chown www-data -R /var/www/html

VOLUME ["/var/www/html"]

ADD 01-enable_modules.start /etc/local.d
ADD 02-apply_environment.start /etc/local.d
ADD php-production.ini /usr/local/etc/php/
ADD php-development.ini /usr/local/etc/php/

ENV TIMEZONE GMT
ENV PHP_MODULES opcache
ENV TERM xterm

#    ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h &&  \

EXPOSE 9000

ENTRYPOINT [ "/bin/bash", "--init-file", "/root/rc" ]
