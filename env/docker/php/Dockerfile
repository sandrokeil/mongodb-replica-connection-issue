FROM php:7.1.2-fpm-alpine

ENV PHP_MONGO_VERSION 1.2.5

# persistent / runtime deps
ENV PHPIZE_DEPS \
    autoconf \
    cmake \
    file \
    g++ \
    gcc \
    libc-dev \
    make \
    git \
    pkgconf \
    re2c

RUN apk add --no-cache --virtual .persistent-deps \
    # for mongodb
    libssl1.0

RUN set -xe \
    && apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        openssl-dev \
    && git clone --branch ${PHP_MONGO_VERSION} https://github.com/mongodb/mongo-php-driver /tmp/php-mongo \
        && cd /tmp/php-mongo \
        && git submodule sync && git submodule update --init \
        && phpize  \
        && ./configure  \
        && make  \
        && make install \
        && make test \
    && docker-php-ext-configure opcache --enable-opcache \
        && docker-php-ext-install opcache \
    && apk del .build-deps \
    && rm -rf /tmp/* \
    && rm -rf /var/www \
    && mkdir -p /var/www

# Possible values for ext-name:
# bcmath bz2 calendar ctype curl dba dom enchant exif fileinfo filter ftp gd gettext gmp hash iconv imap interbase intl
# json ldap mbstring mcrypt mssql mysql mysqli oci8 odbc opcache pcntl pdo pdo_dblib pdo_firebird pdo_mysql pdo_oci
# pdo_odbc pdo_pgsql pdo_sqlite pgsql phar posix pspell readline recode reflection session shmop simplexml snmp soap
# sockets spl standard sybase_ct sysvmsg sysvsem sysvshm tidy tokenizer wddx xml xmlreader xmlrpc xmlwriter xsl zip

# Copy configuration
COPY config/php.ini /usr/local/etc/php/
COPY config/php7.ini /usr/local/etc/php/conf.d/
COPY config/mongodb.ini /usr/local/etc/php/conf.d/
COPY config/opcache.ini $PHP_INI_DIR/conf.d/
COPY config/fpm/php-fpm.conf /usr/local/etc/
COPY config/fpm/pool.d /usr/local/etc/pool.d

WORKDIR /var/www
