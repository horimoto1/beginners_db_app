#!/bin/bash

cd /srv/beginners_db_app
git checkout master
git pull

docker-compose -f docker-compose.prod.yml run rails bundle install --without test development
# docker-compose -f docker-compose.prod.yml run rails yarn install
docker-compose -f docker-compose.prod.yml run rails rails assets:precompile RAILS_ENV=production
