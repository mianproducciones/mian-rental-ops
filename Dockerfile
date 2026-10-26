FROM php:8.3-apache

RUN apt-get update \
    && apt-get install -y --no-install-recommends git libpq-dev libonig-dev libcurl4-openssl-dev libzip-dev unzip \
    && docker-php-ext-install pdo_pgsql mbstring curl zip \
    && a2enmod rewrite headers expires \
    && rm -rf /var/lib/apt/lists/*

ENV PORT=10000
WORKDIR /var/www/html

COPY mian-rental-ops-v5.0.0-render.gitbundle /tmp/mian-rental-ops.bundle
RUN rm -rf /tmp/mian-app \
    && git clone /tmp/mian-rental-ops.bundle /tmp/mian-app \
    && rm -rf /tmp/mian-app/.git \
    && rm -rf /var/www/html/* \
    && cp -a /tmp/mian-app/. /var/www/html/ \
    && rm -rf /tmp/mian-app /tmp/mian-rental-ops.bundle \
    && sed -ri 's/^Listen 80$/Listen ${PORT}/' /etc/apache2/ports.conf \
    && sed -ri 's/<VirtualHost \\*:80>/<VirtualHost *:${PORT}>/' /etc/apache2/sites-available/000-default.conf \
    && mkdir -p /var/www/html/storage \
    && chown -R www-data:www-data /var/www/html/storage \
    && chmod -R 750 /var/www/html/storage

COPY docker/entrypoint.sh /usr/local/bin/mro-entrypoint
RUN chmod +x /usr/local/bin/mro-entrypoint

EXPOSE 10000
ENTRYPOINT ["/usr/local/bin/mro-entrypoint"]
CMD ["apache2-foreground"]
