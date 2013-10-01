env :PATH, "#{ENV["PATH"]}:/usr/local/bin/bundle"

every 4.hours do
  rake 'uberzeit:sync:ldap'
end

every 15.minutes do
  rake 'uberzeit:sync:customers'
end

every 1.day do
  rake 'uberzeit:generate:planned_working_time'
end
