source 'https://rubygems.org'

gem 'rails', '3.2.13'

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
  gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
  gem 'zurb-foundation', '~> 4.0.0'
  gem 'font-awesome-sass-rails'
end

gem 'jquery-rails'
gem 'foundation_rails_helper'

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

# regular tasks
gem 'whenever'

# calendar
gem 'calendar_helper', github: 'topfunky/calendar_helper'

# rails localization
gem 'rails-i18n', branch: 'rails-3-x'
gem 'i18n-js', :git => 'git://github.com/fnando/i18n-js.git', :branch => 'master'

gem 'simple-navigation'

# Logging
gem 'uberlog',
  git: 'git@git.nine.ch:gems/uberlog',
  tag: '0.4.1'

group :development, :test do
  gem 'sqlite3'
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
  gem 'i18n-missing_translations'
  gem 'capistrano_database_yml'
  gem 'timecop'
end

group :development do
  gem 'capistrano', '~> 2.13.0'
  gem 'capistrano-maintenance'
  gem 'version_bumper'
  gem 'meta_request'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'sextant'
end
