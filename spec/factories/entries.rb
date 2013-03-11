FactoryGirl.define do
  factory :entry do
    factory :time_entry, class: TimeEntry, parent: Entry do
      ignore do
        duration UberZeit::Config[:work_per_day]
        time_type :work
      end

      type 'TimeEntry'
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

    factory :date_entry, class: DateEntry, parent: Entry do
      ignore do
        time_type :work
      end

      type 'DateEntry'
      time_sheet
      start_date { Date.today }
      end_date { Date.today }

      after(:build) do |entry, evaluator|
        entry.time_type = TEST_TIME_TYPES[evaluator.time_type]
      end

      factory :invalid_date_entry do
        end_date { start_date - 1.day }
      end
    end

  end
end
