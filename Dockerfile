FROM php:7.2-fpm
LABEL maintainer="Rui Fernandes (@bitkill)"

# Install "curl", "libmemcached-dev", "libpq-dev", "libjpeg-dev",
# "libpng-dev", "libfreetype6-dev", "libssl-dev", "libmcrypt-dev",
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    curl \
    libmemcached-dev \
    libz-dev \
    libpq-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libssl-dev \
    libmcrypt-dev \
    libxml2-dev \
    cron \
    supervisor \
    procps \
  && rm -rf /var/lib/apt/lists/*

  # Install the PHP pdo_mysql extention
RUN docker-php-ext-install pdo_mysql \
    # for xlsx file generation
    && docker-php-ext-install xml \
    && docker-php-ext-install xmlwriter \
    && docker-php-ext-install zip \
  # Install the PHP pdo_pgsql extention
  && docker-php-ext-install pdo_pgsql \
  # Install the PHP gd library
  && docker-php-ext-configure gd \
    --enable-gd-native-ttf \
    --with-jpeg-dir=/usr/lib \
    --with-freetype-dir=/usr/include/freetype2 && \
    docker-php-ext-install gd && \
    #update pecl channel
    pecl channel-update pecl.php.net && \
    # redis lib
    pecl install redis-3.1.6 \
    && docker-php-ext-enable redis

RUN echo "memory_limit=2048M" > $PHP_INI_DIR/conf.d/memory-limit.ini
RUN echo "max_execution_time=900" >> $PHP_INI_DIR/conf.d/memory-limit.ini
RUN echo "post_max_size=20M" >> $PHP_INI_DIR/conf.d/memory-limit.ini
RUN echo "upload_max_filesize=20M" >> $PHP_INI_DIR/conf.d/memory-limit.ini

# Disable expose PHP
RUN echo "expose_php=0" > $PHP_INI_DIR/conf.d/path-info.ini

RUN touch /var/log/cron.log

WORKDIR /var/www

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm -rf /tmp/pear

COPY php7.ini /usr/local/etc/php/php.ini

#EXPOSE 9000
#ENTRYPOINT ["php-fpm"]
#CMD ["php artisan --env=production --tries=3 --timeout=3600 queue:listen --queue=important,urgent,high,default"]
