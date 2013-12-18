source 'https://rubygems.org'

gem 'rails', '3.2.14'

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
  gem 'zurb-foundation', '~> 4.2.0'
  gem 'font-awesome-rails', '~> 3.2'
end

gem 'jquery-rails'
gem 'foundation_rails_helper'

# Authentication
gem 'omniauth'
gem 'omniauth-cas'
gem 'omniauth-ldap'
gem 'omniauth-password',
  :github => 'ninech/omniauth-password',
  :branch => 'fix-uid'

# Authorization
gem 'cancan'
gem 'rolify'

# sync
gem 'version_reader'
gem 'airbrake'
gem 'jbuilder'

gem 'validates_timeliness'
gem 'acts_as_paranoid', '~>0.4.0'

# regular tasks
gem 'whenever'

# calendar
gem 'calendar_helper', '~> 0.2'

# rails localization
gem 'rails-i18n', branch: 'rails-3-x'
gem 'i18n-js', :git => 'git://github.com/fnando/i18n-js.git', :branch => 'master'

# navigation
gem 'simple-navigation'

# raf <3 CORS
gem 'rack-cors'

gem 'gaffe'
gem 'kaminari'

gem 'http_accept_language'

# API
# http://www.youtube.com/watch?v=mqgiEQXGetI
gem 'grape', git: 'git://github.com/intridea/grape.git'
gem 'grape-entity', git: 'git://github.com/intridea/grape-entity.git'
gem 'grape-swagger'
gem 'warden'

group :development, :test do
  gem 'sqlite3'
  gem 'mysql2'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'ci_reporter'
  gem 'brakeman'
  gem 'simplecov', :require => false
  gem 'simplecov-rcov', :require => false
  gem 'factory_girl_rails', require: false
  gem 'faker'
  gem 'capybara'
  gem 'i18n-missing_translations'
  gem 'capistrano_database_yml'
  gem 'timecop'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'fivemat'
  gem 'annotate'
  gem 'parallel_tests'
  gem 'guard-spring'
  gem 'selenium-webdriver'
end

group :development do
  gem 'capistrano', '~> 2.13.0'
  gem 'capistrano-maintenance'
  gem 'version_bumper'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'sextant'
  gem 'meta_request'
end

# NINE SPECIFIC GEMS
# ==================
gem 'uberlog',
  git: 'git@git.nine.ch:gems/uberlog',
  tag: '0.4.1'

# Customers
gem 'mynine-plugin_helpers',
    require: 'plugin_helpers',
    git: 'git@git.nine.ch:mynine/plugin_helpers.git',
    branch: 'master'
gem 'mynine-customer_plugin',
    require: 'customer_plugin',
    git: 'git@git.nine.ch:mynine/customer_plugin.git',
    branch: 'master'

# Extensions
gem 'nine-ldap',
    git: 'git@git.nine.ch:nine-ldap.git',
    branch: 'master'

gem 'uberzeit_ninech_customizations',
  git: 'git@git.nine.ch:uberzeit_ninech_customizations',
  branch: 'master'
