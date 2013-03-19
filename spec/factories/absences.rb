FactoryGirl.define do
  factory :absence do
    ignore do
      time_type :work
    end

    time_sheet
    start_date { Date.today }
    end_date { Date.today }

    after(:build) do |entry, evaluator|
      entry.time_type = TEST_TIME_TYPES[evaluator.time_type]
    end

    factory :invalid_absence do
      end_date { start_date - 1.day }
    end
  end
end
