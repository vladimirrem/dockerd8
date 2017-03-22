# from https://www.drupal.org/requirements/php#drupalversions
FROM php:7.1-apache
ARG DEBIAN_FRONTEND=noninteractive

# install the PHP extensions we need
RUN apt-get update && apt-get install -y \
    vim \
    git \
    unzip \
    wget \
    curl \
    libmcrypt-dev \
    libgd2-dev \
    libgd2-xpm-dev \
    libcurl4-openssl-dev \
    mysql-client

RUN docker-php-ext-install -j "$(nproc)" iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/  --with-png-dir=/usr \
    && docker-php-ext-install -j "$(nproc)" gd  pdo pdo_mysql curl mbstring opcache

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=60'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
  } > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Install Composer
RUN curl -sS https://getcomposer.org/installer | \
    php -- --install-dir=/usr/bin/ --filename=composer

# Install PHPUnit
RUN curl -sSL https://phar.phpunit.de/phpunit.phar -o phpunit.phar && \
  chmod +x phpunit.phar && \
  mv phpunit.phar /usr/local/bin/phpunit

RUN a2enmod rewrite

# Install Xdebug support
RUN pecl install xdebug \
  && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
  && echo "xdebug.idekey = PHPSTORM" >> /usr/local/etc/php/conf.d/xdebug.ini \
  && echo "xdebug.default_enable = 1" >> /usr/local/etc/php/conf.d/xdebug.ini \
  && echo "xdebug.remote_enable = 1" >> /usr/local/etc/php/conf.d/xdebug.ini \
  && echo "xdebug.remote_handler = dbgp" >> /usr/local/etc/php/conf.d/xdebug.ini \
  && echo "xdebug.remote_port = 9000" >> /usr/local/etc/php/conf.d/xdebug.ini \
  && echo "xdebug.remote_autostart = 1" >> /usr/local/etc/php/conf.d/xdebug.ini \
  && echo "xdebug.remote_connect_back = 0" >> /usr/local/etc/php/conf.d/xdebug.ini \
  && echo "xdebug.profiler_enable = 0" >> /usr/local/etc/php/conf.d/xdebug.ini \
  && echo "xdebug.remote_host = 10.254.254.254" >> /usr/local/etc/php/conf.d/xdebug.ini \
  && echo "xdebug.max_nesting_level = 256" >> /usr/local/etc/php/conf.d/xdebug.ini \
  && echo "xdebug.remote_log = /tmp/xdebug.log" >> /usr/local/etc/php/conf.d/xdebug.ini

WORKDIR /var/www/html

# sSMTP: note php is configured to use ssmtp, which is configured to send to
# pmmimail:1025, which is standard configuration for a mailhog/mailhog image
# with hostname mail.
#RUN apt-get install ssmtp -y
#COPY ./config/ssmtp/ssmtp.conf /etc/ssmtp/ssmtp.conf
