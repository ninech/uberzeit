source "https://nine:nineball@gem-repo.nine.ch"
source 'https://rubygems.org'

gem 'rails', '3.2.12'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

# LDAP
gem 'nine-ldap'

gem "version_reader"
gem "airbrake"
gem "jbuilder"


group :development, :test do
  gem "rspec"
  gem "rspec-rails"
  gem "ci_reporter"
  gem "brakeman"
  gem "simplecov", :require => false
  gem "simplecov-rcov", :require => false
  gem "factory_girl_rails"
  gem 'faker'
end

group :development do
  gem "capistrano"
  gem "capistrano-maintenance"
  gem "version_bumper"
  gem "meta_request"
  gem "better_errors"
  gem "binding_of_caller"
  gem "sextant"
end
