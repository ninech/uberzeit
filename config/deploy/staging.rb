server 'webtools8-staging.nine.ch', :app, :web, :db, primary: true
set :rails_env, 'staging'
set :branch, 'develop'

set :deploy_to, '/home/www-data/uberzeit-staging'
