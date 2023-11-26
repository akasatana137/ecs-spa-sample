#!/bin/sh

echo DB_HOST=$DB_HOST >> backend/.env &&
echo DB_DATABASE=$DB_DATABASE >> backend/.env &&
echo DB_USERNAME=$DB_USERNAME >> backend/.env &&
echo DB_PASSWORD=$DB_PASSWORD >> backend/.env &&
echo APP_NAME=$APP_NAME >> backend/.env &&
echo APP_KEY=$APP_KEY >> backend/.env &&
echo APP_ENV=$APP_ENV >> backend/.env &&
echo APP_DEBUG=$APP_DEBUG >> backend/.env &&
echo 'Laravel env variables configured'
