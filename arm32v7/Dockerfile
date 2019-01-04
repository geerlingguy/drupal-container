FROM resin/rpi-raspbian:stretch

# Install Apache, PHP
RUN sudo apt-get update \
    && sudo apt-get install -y \
       apache2 libapache2-mod-php libpcre3-dev \
       php7.0-common php7.0-dev php7.0-gd php7.0-curl php7.0-imap php7.0-json php7.0-opcache php7.0-xml php7.0-mbstring php7.0-mysql php-apcu \
       mysql-client \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN a2enmod rewrite

RUN rm -f /etc/apache2/sites-enabled/000-default.conf
COPY vhosts.conf /etc/apache2/sites-enabled/vhosts.conf

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh / # For backwards compatibility.
ENTRYPOINT ["docker-entrypoint.sh"]

WORKDIR "/var/www/html"

EXPOSE 80
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
