FactoryGirl.define do
  factory :time_entry do
    ignore do
      duration UberZeit::Config[:work_per_day]
      time_type :work
    end

    time_sheet
    start_date { Time.current.to_date.to_s(:db) }
    from_time { '8:00' }
    to_time   { '12:00' }

    after(:build) do |entry, evaluator|
      entry.time_type = TEST_TIME_TYPES[evaluator.time_type]
    end

    factory :invalid_time_entry do
      to_time { from_time }
    end
  end
end
