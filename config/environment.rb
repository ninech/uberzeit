# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Uberzeit::Application.initialize!

# Overidde the environment TZ variable to UTC
# We are not interested in the servertime if we call time functions like Time.now
ENV['TZ'] = 'utc'
