#! /bin/bash
# Author: Jorge González (@scrubmx)
# https://github.com/scrubmx/Shell-Scripts/edit/master/mkwp.sh
#

function _remove_wp_folders(){
	mv wordpress/* ./
	rmdir wordpress
	rm *.tar.gz
}

function _install_wordpress(){
	wget $1
	printf '\033[0;34m%s\033[0m\n\n' "Extracting files and cleaning up..."
	tar xzf *.tar.gz
	_remove_wp_folders
}


function _prompt_create_users(){
	printf '\n\033[0;34m%s\033[0m' "Do you want to create default users? [Y/N] "
	read users
	if [ $users != Y ] || [ $users != y ]; then
		rm -f ./wp-content/themes/base-theme/inc/users.php
	fi
}

function _setup_base_theme(){
	printf '\n\033[0;34m%s\033[0m\n\n' "Downloading HacemosCodigo base-theme..."
	git clone git@github.com:HacemosCodigo/base-theme.git ./wp-content/themes/base-theme
	rm -rf ./wp-content/themes/base-theme/.git
	_prompt_create_users
}

function _prompt_base_theme(){
	printf '\033[0;34m%s\033[0m' "Do you want to use the base-theme? [Y/N] "
	read theme
	if [ $theme = Y ] || [ $theme = y ]; then
		_setup_base_theme
	fi
}

# Select WordPress installation language.
printf '\033[0;34m%s\033[0m' "Instalar WordPress en español? [Y/N] "
read spanish

printf '\n\033[0;34m%s\033[0m\n\n' "Downloading WordPress..."


if [ $spanish = Y ] || [ $spanish = y ]; then
	_install_wordpress "http://es.wordpress.org/wordpress-3.6.1-es_ES.tar.gz"
else
	_install_wordpress "http://wordpress.org/latest.tar.gz"
fi

_prompt_base_theme

printf '\n\033[0;34m%s\033[0m\n\n' "Enter your database information:"

read -r  -p "Database Name: "     dbname
read -r  -p "Database Username: " dbuser
read -rs -p "Database Password: " dbpass

if [ $spanish = Y ] || [ $spanish = y ]; then
	sed -e s/nombredetubasededatos/$dbname/ -e s/nombredeusuario/$dbuser/ -e s/contraseña/$dbpass/ -e "s/'WP_DEBUG', false/'WP_DEBUG', true/" wp-config-sample.php > wp-config.php
else
	sed -e s/database_name_here/$dbname/ -e s/username_here/$dbuser/ -e s/password_here/$dbpass/ -e "s/'WP_DEBUG', false/'WP_DEBUG', true/" wp-config-sample.php > wp-config.php
fi

rm wp-config-sample.php
echo ""

cat << EOF > .htaccess
# Default Charset
AddDefaultCharset utf-8

# Web Fonts
AddType application/font-woff         woff
AddType application/vnd.ms-fontobject eot
AddType application/x-font-ttf        ttf
AddType font/opentype                 otf

# BEGIN WordPress
RewriteEngine On
RewriteBase /
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]

# END WordPress
EOF

printf '\n\033[0;32m%s\033[0m\n' 'WordPress was sucesfully installed!'
