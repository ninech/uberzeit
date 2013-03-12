FactoryGirl.define do
  factory :time_entry do
    ignore do
      duration UberZeit::Config[:work_per_day]
      time_type :work
    end

    time_sheet
    start_time { Time.zone.now }
    end_time { start_time + duration }

    after(:build) do |entry, evaluator|
      entry.time_type = TEST_TIME_TYPES[evaluator.time_type]
    end

    factory :invalid_time_entry do
      end_time { start_time }
    end
  end
end
