#!/bin/sh
set -e
mkdir -p /var/www/html/storage
chown -R www-data:www-data /var/www/html/storage 2>/dev/null || true
chmod 750 /var/www/html/storage 2>/dev/null || true
exec "$@"
