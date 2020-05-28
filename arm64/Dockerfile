FROM debian:buster-slim

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Add Ondrej Sury's apt repo and requirements.
RUN apt-get update \
    && apt-get install -y apt-transport-https lsb-release ca-certificates curl wget git \
    && wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
    && rm -rf /var/lib/apt/lists/*

# Install Apache, PHP
RUN apt-get update \
    && apt-get install -y \
       apache2 libapache2-mod-php libpcre3-dev unzip \
       php7.3-common php7.3-dev php7.3-gd php7.3-curl php7.3-imap php7.3-json php7.3-opcache php7.3-xml php7.3-mbstring php7.3-mysql php7.3-zip php-apcu \
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
