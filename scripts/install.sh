#!/usr/bin/env bash

echo "=== Downloading Drupal 8.2.7 ==="
wget https://ftp.drupal.org/files/projects/drupal-8.2.7.tar.gz
tar xvzf drupal-8.2.7.tar.gz
rm drupal-8.2.7.tar.gz
mv drupal-8.2.7 html
cd html
rm README.txt
rm sites/README.txt
rm modules/README.txt
rm themes/README.txt
rm sites/example.sites.php
mkdir modules/custom
mkdir modules/contrib
mkdir libraries
mkdir sites/default/files
chmod 777 -R sites/default/files
cd ../
docker-compose up -d --build
sudo chmod 777 -R ./data
docker-compose exec web bash -ci "composer require drush/drush:^8.1"
docker-compose exec web bash -ci "composer config repositories.drupal composer https://packages.drupal.org/8"
dru site-install standard --account-name=admin --account-pass=admin  --site-name=test --db-url=mysql://drupal:drupal@data_db:/drupal -y
#clear

