#!/bin/sh
set -eu

mkdir -p /var/www/html/storage
chown -R www-data:www-data /var/www/html/storage 2>/dev/null || true
chmod 750 /var/www/html/storage 2>/dev/null || true

if [ -n "${DATABASE_URL:-}" ]; then
  echo "[MRO] Preparando esquema PostgreSQL..."
  php /var/www/html/cli/migrate.php

  if [ -n "${OWNER_EMAIL:-}" ] && [ -n "${OWNER_PASSWORD:-}" ]; then
    OWNER_EXISTS="$(php -r 'require "/var/www/html/lib/bootstrap.php"; $email=strtolower(trim((string)(getenv("OWNER_EMAIL")?:""))); $s=db()->prepare("SELECT COUNT(*) FROM users WHERE LOWER(email)=?"); $s->execute([$email]); echo ((int)$s->fetchColumn()>0)?"1":"0";')"
    if [ "$OWNER_EXISTS" != "1" ]; then
      echo "[MRO] Creando cuenta SuperAdmin inicial..."
      php /var/www/html/cli/bootstrap_owner.php
    else
      echo "[MRO] SuperAdmin inicial ya existe."
    fi
  else
    echo "[MRO] OWNER_EMAIL/OWNER_PASSWORD no configurados; se omite el alta inicial."
  fi
else
  echo "[MRO] DATABASE_URL todavía no está configurada."
fi

exec "$@"
