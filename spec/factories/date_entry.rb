FactoryGirl.define do
  factory :date_entry, class: DateEntry, parent: Entry do
    ignore do
      type :work
    end

    time_sheet
    start_date { Date.today }
    end_date { Date.today }

    after(:build) do |entry, evaluator|
      entry.time_type = TEST_TIME_TYPES[evaluator.type]
    end

    factory :invalid_date_entry do
      end_date { start_date - 1.day }
    end
  end
end
