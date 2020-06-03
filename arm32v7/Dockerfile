FROM balenalib/raspberrypi3-debian:buster

# Add Ondrej Sury's apt repo and requirements.
RUN sudo apt-get update \
    && sudo apt-get install apt-transport-https lsb-release ca-certificates wget git \
    && sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
    && rm -rf /var/lib/apt/lists/*

# Install Apache, PHP
RUN sudo apt-get update \
    && sudo apt-get install -y \
       apache2 libapache2-mod-php libpcre3-dev unzip \
       php7.4-common:armhf php7.4-dev:armhf php7.4-gd:armhf php7.4-curl:armhf php7.4-imap:armhf php7.4-json:armhf php7.4-opcache:armhf php7.4-xml:armhf php7.4-mbstring:armhf php7.4-mysql:armhf php7.4-zip:armhf php-apcu:armhf \
       mariadb-client \
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
