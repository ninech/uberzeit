# uberZeit

![Time Reporting](doc/images/time_reporting.png)

## Installation on your production server

The installation has been tested on Ubuntu 12.04.

### Packages / Dependencies

    apt-get update
    apt-get install libxml2 libxml2-dev libxslt-dev libcurl4-openssl-dev ruby1.9.1 ruby1.9.1-dev postgresql-9.1 libpq-dev git build-essential
    gem install bundler


### Setup

#### Clone repository

    cd /to/installation/directory
    git clone https://github.com/ninech/uberzeit.git .

#### Install needed Gems

    bundle install --without development test

#### Setup database

    cp config/database.yml.example config/database.yml

Now add a database user and adjust database.yml accordingly.
Then set up the database:

    RAILS_ENV=production bundle exec rake db:create db:migrate db:seed


#### Precompile assets

    RAILS_ENV=production bundle exec rake assets:precompile


#### Copy initial app settings

    cp config/uberzeit.yml.example config/uberzeit.yml


#### Setup environment variables

    cp config/.env.example config/.env

Edit `.env` and change the value of `SECRET_TOKEN` to a random alphanumeric string.
You could for example use `pwgen -s -1 100` to generate a random string.

#### Start the app

    RAILS_ENV=production bundle exec thin start -e production

Now visit http://hostname:3000 and sign in with `admin@example.org`, password `admin`. Enjoy!


## Deployment on Heroku

To deploy on Heroku, there are some modifications needed. The configuration must
also be added to the repository.
We do this with hidden branch `deploy` which will be pushed to Heroku only.

#### Clone repository

    cd /to/installation/directory
    git clone https://github.com/ninech/uberzeit.git .

### Setup Heroku

    heroku create
    git checkout -b deploy
    bundle install --without development test

#### Prepare heroku modifications

    bundle exec rake i18n:js:export
    git add app/assets/javascripts/i18n/translations.js
    git commit -m 'add i18n translations'

### Configure

    cp config/uberzeit.yml.example config/uberzeit.yml
    # Edit config/uberzeit.yml to fit your needs
    git add -f config/uberzeit.yml
    git commit -m 'add configuration'
    heroku config:set SECRET_TOKEN=`pwgen -s -1 100`

### Deploy To Heroku

    git push heroku deploy:master
    heroku run rake db:migrate db:seed

## API

    curl -v -H 'X-Auth-Token: YourSuperSecretToken' -X GET uberzeit.dev/api/ping
