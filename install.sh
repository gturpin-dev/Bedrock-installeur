#!/usr/bin/env bash

################################
# Ask for variable
################################
echo "Quel est le nom de votre projet ?"
read project_name
echo "------------------------"
echo "DB_NAME ?"
read db_name
echo "------------------------"
echo "DB_USER ?"
read db_user
echo "------------------------"
echo "DB_PASSWORD ?"
read db_password
echo "------------------------"
echo "DB_PREFIX ?"
read db_prefix
echo "------------------------"
echo "Quel est l'identifiant du compte admin ?"
read site_id
echo "------------------------"
echo "Quel est le mot de passe du compte admin ?"
read site_passwd
echo "------------------------"
echo "Quel est l'email du compte admin ?"
read site_mail

################################
# Init Project
################################
composer create-project roots/bedrock $project_name
cd $project_name
rm .env
wp dotenv init --with-salts --force
wp dotenv set DB_NAME $db_name
wp dotenv set DB_USER $db_user
wp dotenv set DB_PASSWORD $db_password
wp dotenv set DB_PREFIX $db_prefix
wp dotenv set WP_ENV development
wp dotenv set WP_HOME http://localhost:8000
wp dotenv set WP_SITEURL \$\{WP_HOME\}/wp

################################
# Init Wordpress
################################
wp core install --url='http://localhost:8000' --title=$project_name --admin_user=$site_id --admin_password=$site_passwd --admin_email=$site_mail
wp core update

################################
# Delete Installation folder
################################
cd ..
mv ./Makefile $project_name
mv $project_name ..
cd ..
rm -rf Bedrock-installeur
