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
  gem 'compass-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
  gem 'zurb-foundation', '~> 4.0.0'
  gem 'font-awesome-sass-rails'
end

gem 'jquery-rails'
gem 'turbolinks'
gem 'jquery-turbolinks'

# Authentication
gem 'omniauth'
gem 'omniauth-cas'
gem 'omniauth-ldap'

# Authorization
gem 'cancan'
gem 'rolify'

# sync
# Extensions
gem 'nine-ldap',
    git: 'git@git.nine.ch:nine-ldap.git',
    tag: '0.0.13'

# To use local Git repos, run this on console:
# bundle config local.nine-ldap ~/projects/nine-ldap

gem 'version_reader'
gem 'airbrake'
gem 'jbuilder'

gem 'validates_timeliness'
gem 'acts_as_paranoid', '~>0.4.0'

gem 'ice_cube'

# regular tasks
gem 'whenever'

# calendar
gem 'calendar_helper'

group :development, :test do
  gem 'mysql2'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'ci_reporter'
  gem 'brakeman'
  gem 'simplecov', :require => false
  gem 'simplecov-rcov', :require => false
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'capybara'
end

group :development do
  gem 'capistrano'
  gem 'capistrano-maintenance'
  gem 'version_bumper'
  gem 'meta_request'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'sextant'
end
