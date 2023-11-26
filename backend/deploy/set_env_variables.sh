#!/bin/sh

echo DB_HOST=$DB_HOST >> laravel/.env &&
echo DB_DATABASE=$DB_DATABASE >> laravel/.env &&
echo DB_USERNAME=$DB_USERNAME >> laravel/.env &&
echo DB_PASSWORD=$DB_PASSWORD >> laravel/.env &&
echo APP_NAME=$APP_NAME >> laravel/.env &&
echo APP_KEY=$APP_KEY >> laravel/.env &&
echo APP_ENV=$APP_ENV >> laravel/.env &&
echo APP_DEBUG=$APP_DEBUG >> laravel/.env &&
echo 'Laravel env variables configured'
