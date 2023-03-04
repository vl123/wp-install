#!/bin/bash

# functions
generate_password()
{
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1
}

# variables
SERVER_ROOT="www/"
SITE_URL_PREFIX="site/"
DB_USER="user"
DB_PASS="password"
DB_PREFIX="wp_"
WP_EMAIL="email@localhost"
WP_USER_PREFIX="admin-"
WP_PASS=$(generate_password)

THEMES_TO_REMOVE=("twentytwentyone" "twentytwentytwo")
PLUGINS_TO_REMOVE=("hello")

if [ $1 ]
then
	SITE_URL_DOMAIN=$SITE_URL_PREFIX$1
	WP_USER=$WP_USER_PREFIX$1
	
	echo "Site domain: $SITE_URL_DOMAIN"
	echo "WP login: $WP_USER"
	echo "WP password: $WP_PASS"
	
	wp core download --path=$SERVER_ROOT$1
	cd $SERVER_ROOT$1/
	wp core config --dbname=$1 --dbuser=$DB_USER --dbpass=$DB_PASS --dbprefix=$DB_PREFIX
	wp db create
	wp core install --url=$SITE_URL_DOMAIN --title=$1 --admin_user=$WP_USER --admin_password=$WP_PASS --admin_email=$WP_EMAIL --skip-email
	
	# delete unused themes
	for THEME_NAME in "${THEMES_TO_REMOVE[@]}"
	do
	   wp theme delete $THEME_NAME
	done

	# delete unused plugins
	for PLUGIN_NAME in "${PLUGINS_TO_REMOVE[@]}"
	do
	   wp plugin delete $PLUGIN_NAME
	done
	
	# delete default post and page
	wp post delete $(wp post list --post_type=page,post --format=ids) --force
	
	# change settings
	wp option set blog_public 0 # discourage search engines from indexing this site
	
	echo "That's all folks!"
else
  echo "Usage: wp-install.sh sitename"
fi