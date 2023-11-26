#!/bin/sh
seeders=()
if [ ${#seeders[@]} -gt 0 ]; then
  composer dump-autoload
  for seeder_class in ${seeders[@]}; do
   php artisan db:seed --class=$seeder_class
  done
fi
