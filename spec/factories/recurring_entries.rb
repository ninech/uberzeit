# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :recurring_entry do
    ignore do
      type :work
      attribs { {start_time: Time.zone.now, end_time: Time.zone.now + 1.hour} }
    end

    time_sheet
    schedule_attributes { {repeat_unit: 'daily', daily_repeat_every: 1, ends: 'never'}.merge(attribs) }

    after(:build) do |entry, evaluator|
      entry.time_type = FactoryGirl.create("time_type_#{evaluator.type}")   
    end

    factory :invalid_recurring_entry do
      time_type_id nil 
    end
  end
end
