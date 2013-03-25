require 'simplecov'
require 'simplecov-rcov'

class SimpleCov::Formatter::MergedFormatter
  def format(result)
    SimpleCov::Formatter::HTMLFormatter.new.format(result)
    SimpleCov::Formatter::RcovFormatter.new.format(result)
  end
end

SimpleCov.formatter(SimpleCov::Formatter::MergedFormatter)
SimpleCov.start 'rails'

require 'i18n/missing_translations'
at_exit { I18n.missing_translations.dump }

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rspec'
require 'capybara/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.before(:suite) do
    TEST_TIME_TYPES = {}
    %w{work vacation break paid_absence onduty}.each do |time_type|
      TEST_TIME_TYPES[time_type.to_sym] = FactoryGirl.create("time_type_#{time_type}", name: "test_#{time_type}")
    end
  end

  config.before(:each) do
    # Overwrite uZ config with default values
    uberzeit_config = {
      rounding: 1.minutes,
      work_days:  [:monday, :tuesday, :wednesday, :thursday, :friday],
      work_per_day:  8.5.hours,
      vacation_per_year:  25.days
    }
    stub_const 'UberZeit::Config', uberzeit_config
  end

  config.after(:suite) do
    TEST_TIME_TYPES.each do |name, entry|
      entry.destroy!
    end
  end
end

OmniAuth.config.mock_auth[:cas] = OmniAuth::AuthHash.new({
  :provider => 'cas',
  :uid => 'user1'
})
OmniAuth.config.test_mode = true

