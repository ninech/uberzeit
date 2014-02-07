require 'simplecov'
require 'simplecov-rcov'
require 'factory_girl_rails'

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

# Make sure language matches for feature specs
I18n.available_locales = [:de]

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
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # In Rails, HTTP request tests would go into the spec/requests group. You may
  # want your API code to go into app/api - you can match that layout under
  # spec by adding the following in spec/spec_helper.rb.
  config.include RSpec::Rails::RequestExampleGroup, type: :request, example_group: {
    file_path: /spec\/api/
  }

  Time.zone = 'Bern'


  config.before(:suite) do
    # Begin by cleaning the db
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation

    # Set up time types
    TEST_TIME_TYPES = {}
    %w{work vacation compensation paid_absence onduty}.each do |time_type|
      TEST_TIME_TYPES[time_type.to_sym] = FactoryGirl.create("time_type_#{time_type}", name: "test_#{time_type}")
    end
  end

  config.after(:suite) do
    TEST_TIME_TYPES.each do |name, entry|
      entry.destroy!
    end
  end

  config.before(:each) do
    # GC Optimization
    GC.disable

    # Start database cleaning
    if example.metadata[:js]
      DatabaseCleaner.strategy = :truncation, {except: ['time_types']}
    else
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.start
    end
  end

  run_counter = 0

  config.after(:each) do
    # GC Optimization
    run_counter += 1
    if run_counter % 10 == 0
      GC.enable
      GC.start
      GC.disable
    end

    # Clean database
    DatabaseCleaner.clean

    # Stop those time travellers NOW!
    Timecop.return
  end
end
