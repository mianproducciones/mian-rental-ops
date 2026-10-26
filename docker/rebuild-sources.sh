#!/bin/sh
set -eu
cd /var/www/html
rebuild() {
  dest="$1"
  pattern="$2"
  mkdir -p "$(dirname "$dest")"
  cat $pattern > "$dest"
}
rebuild "assets/app.js" ".srcparts/assets_app.js__*"
rebuild "api.php" ".srcparts/api.php__*"
rebuild "assets/app.css" ".srcparts/assets_app.css__*"
rebuild "lib/bootstrap.php" ".srcparts/lib_bootstrap.php__*"
rebuild "database/schema_pgsql.sql" ".srcparts/database_schema_pgsql.sql__*"
rebuild "admin.php" ".srcparts/admin.php__*"
rm -rf .srcparts
