FROM php:8.3-apache

RUN apt-get update \
    && apt-get install -y --no-install-recommends libpq-dev libonig-dev libcurl4-openssl-dev libzip-dev unzip \
    && docker-php-ext-install pdo_pgsql mbstring curl zip \
    && a2enmod rewrite headers expires \
    && rm -rf /var/lib/apt/lists/*

ENV PORT=10000
WORKDIR /var/www/html
COPY . /var/www/html

RUN chmod +x /var/www/html/docker/rebuild-sources.sh \
    && /var/www/html/docker/rebuild-sources.sh \
    && sed -ri 's/^Listen 80$/Listen ${PORT}/' /etc/apache2/ports.conf \
    && sed -ri 's/<VirtualHost \*:80>/<VirtualHost *:${PORT}>/' /etc/apache2/sites-available/000-default.conf \
    && mkdir -p /var/www/html/storage \
    && chown -R www-data:www-data /var/www/html/storage \
    && chmod -R 750 /var/www/html/storage \
    && chmod +x /var/www/html/docker/entrypoint.sh

EXPOSE 10000
ENTRYPOINT ["/var/www/html/docker/entrypoint.sh"]
CMD ["apache2-foreground"]
