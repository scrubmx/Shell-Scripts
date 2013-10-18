#! /bin/bash
# Author: Jorge González
# https://github.com/scrubmx/
#

function _remove_wp_folders(){
	mv wordpress/* ./
	rmdir wordpress
}

function _install_spanish() {
	wget http://es.wordpress.org/wordpress-3.6.1-es_ES.tar.gz
	printf '\033[0;34m%s\033[0m\n\n' "Extracting files and cleaning up..."
	tar zxf wordpress-*.tar.gz
	rm wordpress-*.tar.gz
	_remove_wp_folders
}

function _install_normal() {
	wget http://wordpress.org/latest.tar.gz
	printf '\033[0;34m%s\033[0m\n\n' "Extracting files and cleaning up..."
	tar zxf latest.tar.gz
	rm latest.tar.gz
	_remove_wp_folders
}

function _setup_base_theme(){
	printf '\033[0;34m%s\033[0m\n\n' "Downloading HacemosCodigo base-theme..."
	git clone git@github.com:HacemosCodigo/base-theme.git ./wp-content/themes/base-theme
	rm -rf ./wp-content/themes/base-theme/.git
}

# Select WordPress installation language.
printf '\033[0;34m%s\033[0m' "Instalar WordPress en español? [Y/N] "
read spanish

printf '\n\033[0;34m%s\033[0m\n\n' "Downloading WordPress..."


if [ $spanish = Y ] || [ $spanish = y ]; then
	_install_spanish
	_setup_base_theme
else
	_install_normal
	_setup_base_theme
fi

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
