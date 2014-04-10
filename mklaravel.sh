#!/bin/bash
# Author: Jorge González (@scrubmx)
#
# Create new laravel Project
# https://github.com/scrubmx/Shell-Scripts/edit/master/mklaravel.sh
#
printf '\n\033[0;34m%s\033[0m' "Create a new Laravel app? [y/n] "
read -e laravel
if [[ $laravel == "yes" || $laravel == "y" ]]
    then
        printf '\n\033[0;34m%s\033[0m' "What is the name of the app? : "
        read appname
        composer create-project laravel/laravel $appname --prefer-dist
        cd $appname
else
    exit 0
fi

# Install and Configure Way/Generators Package
printf '\n\033[0;34m%s\033[0m' "Add Way/Generators to $appname? : [y/n] "
read -e generators
if [[ $generators == "yes" || $laravel == "y" ]]
    then
        printf '\n\033[0;32m%s\033[0m\n' "Adding Way/Generators to $appname..."
        gsed -i '8 a\ "require-dev" : { "way/generators": "dev-master" },' composer.json
        composer update
        gsed -i "115 a\ 'Way\\\Generators\\\GeneratorsServiceProvider'," app/config/app.php
fi

# Update app/bootstrap/start.php with env function
printf '\n\033[0;34m%s\033[0m' "Set up Development Environment? [y/n] "
read -e development
if [[ $development == "yes" || $laravel == "y" ]]
    then
        gsed -i -e'29,33d' bootstrap/start.php
        gsed -i "28 a\ \$env = \$app->detectEnvironment(function() { return getenv('ENV') ?: 'development'; });" bootstrap/start.php
fi

# Create mysql database
printf '\n\033[0;34m%s\033[0m' "Does you app need a database? : [y/n] "
read -e needdb
if [[ $needdb == 'yes' || $laravel == "y" ]]
    then
        printf '\n\033[0;34m%s\033[0m' "What is the name of the database for this app? : "
        read -e database

        printf '\n\033[0;32m%s\033[0m\n' "Creating MySQL database"
        mysql -uroot -p -e"CREATE DATABASE $database"

        printf '\n\033[0;32m%s\033[0m\n' "Updating database configuration file..."
        gsed -i "s/'database'  => 'database',/'database'  => '$database',/g" app/config/database.php
fi

printf '\n\033[0;34m%s\033[0m' "Do you need a users table? [y/n]: "
read -e userstable
if [[ $userstable = 'yes' || $laravel == "y" ]]
    then
        printf '\n\033[0;32m%s\033[0m\n' "Creating Users Table..."
        php artisan generate:migration create_users_table --fields="username:string:unique, email:string:unique, password:string"

        printf '\n\033[0;32m%s\033[0m\n' "Migrating the database..."
        php artisan migrate
fi

printf '\n\033[0;34m%s\033[0m' "Need a Git Repository [y/n]: "
read -e git
if [[ $git == 'yes' || $laravel == "y"  ]]
    then
        printf '\n\033[0;32m%s\033[0m\n' "Initializing Git..."
        git init
        git add .
        git commit -m "initial commit"
fi

printf '\n\033[0;34m%s\033[0m' "Add this Repo to Github? [y/n]: "
read -e github
if [[ $github == 'yes' || $laravel == "y" ]]
    then
        printf '\n\033[0;34m%s\033[0m' "What is your github username? : "
        read githubUsername
        curl -u "$githubUsername" https://api.github.com/user/repos -d "{\"name\":\"$appname\"}"

        git remote add origin git@github.com:$githubUsername/$appname.git
        git push origin master
fi

printf '\n\033[0;32m%s\033[0m\n' "Laravel application was created successfully!"
