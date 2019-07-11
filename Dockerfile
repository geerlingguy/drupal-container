FROM geerlingguy/php-apache:7.3

RUN apt-get update \
    && apt-get install -y mariadb-client git \
    && rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh / # For backwards compatibility.
ENTRYPOINT ["docker-entrypoint.sh"]

WORKDIR "/var/www/html"

EXPOSE 80
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
