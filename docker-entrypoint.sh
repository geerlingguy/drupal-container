#!/bin/bash
#
# Drupal container entrypoint.
#
# This entrypoint script will create a new Drupal codebase if one is not already
# present in the /var/www/html directory.

set -e

# Set Drupal major version.
DRUPAL_DOWNLOAD_VERSION="8.6.x-dev"
DRUPAL_DOWNLOAD_URL="https://ftp.drupal.org/files/projects/drupal-$DRUPAL_DOWNLOAD_VERSION.tar.gz"

# Download Drupal to /var/www/html if it's not present.
if [ ! -f /var/www/html/index.php ]; then
  echo "Removing any existing files inside /var/www/html ..."
  find /var/www/html -type f -maxdepth 1 -delete
  echo "Downloading Drupal $DRUPAL_DOWNLOAD_VERSION ..."
  curl -O $DRUPAL_DOWNLOAD_URL
  echo "Download complete!"
  echo "Expanding Drupal into /var/www/html ..."
  tar -xzf drupal-$DRUPAL_DOWNLOAD_VERSION.tar.gz -C /var/www/html --strip-components=1
  chown -R www-data:www-data /var/www/html
  rm drupal-$DRUPAL_DOWNLOAD_VERSION.tar.gz
  echo "Drupal codebase ready!"
fi

exec "$@"
