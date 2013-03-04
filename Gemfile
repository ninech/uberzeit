source 'https://nine:nineball@gem-repo.nine.ch'
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

gem 'rack-cas'

# LDAP
gem 'nine-ldap'

gem 'version_reader'
gem 'airbrake'
gem 'jbuilder'

gem 'validates_timeliness'
gem 'acts_as_paranoid', '~>0.4.0'

# Gimme beauty... 
gem 'bootstrap-sass', '~> 2.3.0.1'
gem 'bootswatch-rails'

gem 'bootstrap-datepicker-rails'
gem 'jquery-timepicker-rails'

gem 'ice_cube'

group :development, :test do
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
