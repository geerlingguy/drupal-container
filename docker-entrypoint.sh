#!/bin/bash
#
# Drupal container entrypoint.
#
# This entrypoint script will create a new Drupal codebase if one is not already
# present in the APACHE_DOCUMENT_ROOT directory.

set -e

# Allow container to specify skipping cert validation.
DRUPAL_DOWNLOAD_VERIFY_CERT=${DRUPAL_DOWNLOAD_VERIFY_CERT:-true}

# Allow setting the way Drupal is downloaded (tarball, git, composer).
DRUPAL_DOWNLOAD_METHOD=${DRUPAL_DOWNLOAD_METHOD:-tarball}

# Drupal URLs and version options.
DRUPAL_DOWNLOAD_URL="https://www.drupal.org/download-latest/tar.gz"
DRUPAL_CLONE_URL=${DRUPAL_CLONE_URL:-"https://git.drupalcode.org/project/drupal.git"}
DRUPAL_CLONE_BRANCH=${DRUPAL_CLONE_BRANCH:-"8.8.x"}
DRUPAL_PROJECT_VERSION=${DRUPAL_PROJECT_VERSION:-"^8@dev"}

# Allow container to skip the download by setting this to false.
DRUPAL_DOWNLOAD_IF_NOT_PRESENT=${DRUPAL_DOWNLOAD_IF_NOT_PRESENT:-true}

# Allow container to skip composer install step by setting this to false.
DRUPAL_RUN_COMPOSER_INSTALL=${DRUPAL_RUN_COMPOSER_INSTALL:-true}

# Project directories.
APACHE_DOCUMENT_ROOT=${APACHE_DOCUMENT_ROOT:-"/var/www/html"}
DRUPAL_PROJECT_ROOT=${DRUPAL_PROJECT_ROOT:-$APACHE_DOCUMENT_ROOT}

# Allow users to override the docroot by setting an environment variable.
if [ "$APACHE_DOCUMENT_ROOT" != "/var/www/html" ]; then
  sed -ri -e "s|\"/var/www/html\"|\"$APACHE_DOCUMENT_ROOT\"|g" /etc/apache2/sites-enabled/*.conf
  sed -ri -e "s|\"/var/www/html\"|\"$APACHE_DOCUMENT_ROOT\"|g" /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
fi

# Download Drupal to $APACHE_DOCUMENT_ROOT if it's not present.
if [ ! -f $APACHE_DOCUMENT_ROOT/index.php ] && [ $DRUPAL_DOWNLOAD_IF_NOT_PRESENT = true ]; then
  echo "Removing any existing files inside $APACHE_DOCUMENT_ROOT..."
  find $DRUPAL_PROJECT_ROOT -type f -maxdepth 1 -delete || true

  cd $DRUPAL_PROJECT_ROOT
  if [ "$DRUPAL_DOWNLOAD_METHOD" == 'tarball' ]; then
    echo "Downloading Drupal..."
    if [ $DRUPAL_DOWNLOAD_VERIFY_CERT = true ]; then
      curl -sSL $DRUPAL_DOWNLOAD_URL | tar -xz --strip-components=1
    else
      curl -sSLk $DRUPAL_DOWNLOAD_URL | tar -xz --strip-components=1
    fi
    mkdir -p /var/www/config/sync
    echo "Download complete!"
  elif [ "$DRUPAL_DOWNLOAD_METHOD" == 'git' ]; then
    echo "Cloning Drupal..."
    git clone --branch $DRUPAL_CLONE_BRANCH --single-branch $DRUPAL_CLONE_URL .
    echo "Clone complete!"
  elif [ "$DRUPAL_DOWNLOAD_METHOD" == 'composer' ]; then
    composer -n create-project drupal/recommended-project:$DRUPAL_PROJECT_VERSION .
  fi

  echo "Configuring settings.php with environment variables..."
  cp $APACHE_DOCUMENT_ROOT/sites/default/default.settings.php $APACHE_DOCUMENT_ROOT/sites/default/settings.php
  cat <<EOF >> $APACHE_DOCUMENT_ROOT/sites/default/settings.php
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

  echo "Correcting permissions on /var/www..."
  chown -R www-data:www-data /var/www

  if [ $DRUPAL_RUN_COMPOSER_INSTALL = true ] && [ "$DRUPAL_DOWNLOAD_METHOD" != 'composer' ]; then
    echo "Running composer install..."
    composer install
  fi

  echo "Drupal codebase ready!"
fi

exec "$@"
