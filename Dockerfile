FROM ubuntu:latest
MAINTAINER Dmitrii Zolotov <dzolotov@herzen.spb.ru>

# Install packages

ADD sources.list /etc/apt/sources.list

ENV DEBIAN_FRONTEND noninteractive
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db && \
    echo 'deb http://mirror.mephi.ru/mariadb/repo/10.0/debian jessie main' >>/etc/apt/sources.list.d/mariadb.list && \
    echo 'deb-src http://mirror.mephi.ru/mariadb/repo/10.0/debian jessie main' >>/etc/apt/sources.list.d/mariadb.list && \
#    echo 'deb http://packages.dotdeb.org jessie all' >>/etc/apt/sources.list.d/php7.list && \
#    echo 'deb-src http://packages.dotdeb.org jessie all' >> etc/apt/sources.list.d/php7.list && \
    apt-get update && \
    apt-get dist-upgrade -y --allow-unauthenticated && \
    apt-get install -y --allow-unauthenticated mariadb-common php7.0-fpm php7.0-mbstring php7.0-zip php7.0-gd php7.0-mysql php7.0-curl php7.0-opcache php7.0-xsl php7.0-ldap php7.0-redis php7.0-mongo php7.0-imagick php7.0-json php7.0-interbase python-setuptools libmariadbclient18 wget git zip && \
    apt-get clean && \
#    cp /etc/php/mods-available/* /etc/php/7.0/mods-available/ && \
    sed -i 's/listen\s=.*/listen=0.0.0.0:9000/ig' /etc/php/7.0/fpm/pool.d/www.conf && \
    cd /usr/bin && wget https://getcomposer.org/composer.phar && mv composer.phar composer && chmod +x composer && \
    wget http://gordalina.github.io/cachetool/downloads/cachetool.phar && mv cachetool.phar cachetool && chmod +x cachetool && \
    rm -rf /var/lib/apt/lists/* && mkdir -p /run/php && mkdir /var/log/supervisor/ && /usr/bin/easy_install supervisor && /usr/bin/easy_install supervisor-stdout && mkdir /etc/container.run/

#setup php-nginx binding
ADD fastcgi-php.conf /etc/nginx/snippets/fastcgi-php.conf
ADD startFPMWithDockerEnvs.sh /etc/php/7.0/startFPMWithDockerEnvs.sh
ADD php-production.ini /etc/php/7.0/
ADD php-development.ini /etc/php/7.0/
ADD enable_modules /etc/container-run.d/
ADD apply_environment /etc/container-run.d/

# Supervisor Config
ADD supervisord.conf /etc/supervisord.conf

#Attach volume to web-root
VOLUME ["/var/www/html/"]

ENV TIMEZONE GMT
ENV PHP_MODULES opcache phar json
ENV DEBUG false

ADD php-production.ini /usr/local/etc/php/
ADD php-development.ini /usr/local/etc/php/

EXPOSE 9000

CMD ["supervisord","-n","-c","/etc/supervisord.conf"]
