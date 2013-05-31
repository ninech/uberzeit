server 'webtools8.nine.ch', :app, :web, :db, primary: true
set :rails_env, 'production'
set :branch, 'master'

set :deploy_to, '/home/www-data/uberzeit'
