RSpec.configure do |config|
  config.before do
    # Overwrite uZ config with default values
    uberzeit_config = {
      rounding_minutes: 1,
      work_days: %w(monday tuesday wednesday thursday friday),
      ubertrack_hosts: {
        redmine: 'https://redmine.yolo',
        otrs: 'https://otrs.howdoyouturnthison'
      },
      auth_providers: [
        { provider: 'password' },
      ]
    }
    UberZeit.config.clear
    UberZeit.config.merge! uberzeit_config

    Setting.work_per_day_hours = 8.5
    Setting.vacation_per_year_days = 25
  end
end
