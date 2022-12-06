FROM balenalib/raspberrypi3-debian:bullseye

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
       php8.1-common:armhf php8.1-dev:armhf php8.1-gd:armhf php8.1-curl:armhf php8.1-imap:armhf php8.1-opcache:armhf php8.1-xml:armhf php8.1-mbstring:armhf php8.1-mysql:armhf php8.1-zip:armhf php-apcu:armhf \
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
