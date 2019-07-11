#!/bin/bash
#
# Drupal container entrypoint.
#
# This entrypoint script will create a new Drupal codebase if one is not already
# present in the /var/www/html directory.

set -e

# Allow container to specify skipping cert validation.
DRUPAL_DOWNLOAD_VERIFY_CERT=${DRUPAL_DOWNLOAD_VERIFY_CERT:-true}

# Download the latest stable release of Drupal.
DRUPAL_DOWNLOAD_URL="https://www.drupal.org/download-latest/tar.gz"

# Allow container to skip the download by setting this to false.
DRUPAL_DOWNLOAD_IF_NOT_PRESENT=${DRUPAL_DOWNLOAD_IF_NOT_PRESENT:-true}

# Allow users to override the docroot by setting an environment variable.
if [ ! -z "$APACHE_DOCUMENT_ROOT" ]; then
  sed -ri -e "s|\"/var/www/html\"|\"$APACHE_DOCUMENT_ROOT\"|g" /etc/apache2/sites-enabled/*.conf
  sed -ri -e "s|\"/var/www/html\"|\"$APACHE_DOCUMENT_ROOT\"|g" /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
fi

# Download Drupal to /var/www/html if it's not present.
if [ ! -f /var/www/html/index.php ] && [ $DRUPAL_DOWNLOAD_IF_NOT_PRESENT = true ]; then
  echo "Removing any existing files inside /var/www/html..."
  find /var/www/html -type f -maxdepth 1 -delete

  echo "Downloading Drupal..."
  cd /var/www/html
  if [ $DRUPAL_DOWNLOAD_VERIFY_CERT = true ]; then
    curl -sSL $DRUPAL_DOWNLOAD_URL | tar -xz --strip-components=1
  else
    curl -sSLk $DRUPAL_DOWNLOAD_URL | tar -xz --strip-components=1
  fi
  mkdir -p /var/www/config/sync
  echo "Download complete!"

  echo "Configuring settings.php with environment variables..."
  cp /var/www/html/sites/default/default.settings.php /var/www/html/sites/default/settings.php
  cat <<EOF >> /var/www/html/sites/default/settings.php
\$databases['default']['default'] = array (
  'database' => '$DRUPAL_DATABASE_NAME',
  'username' => '$DRUPAL_DATABASE_USERNAME',
  'password' => '$DRUPAL_DATABASE_PASSWORD',
  'prefix' => '',
  'host' => '$DRUPAL_DATABASE_HOST',
  'port' => '$DRUPAL_DATABASE_PORT',
  'namespace' => 'Drupal\\\\Core\\\\Database\\\\Driver\\\\mysql',
  'driver' => 'mysql',
);
\$config_directories['sync'] = '../config/sync';
\$settings['hash_salt'] = '$DRUPAL_HASH_SALT';
EOF

  echo "Correcting permissions on /var/www/html..."
  chown -R www-data:www-data /var/www/html
  echo "Drupal codebase ready!"
fi

exec "$@"
