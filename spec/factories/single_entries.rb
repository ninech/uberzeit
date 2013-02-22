# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :single_entry do
    time_sheet 
    start_time "2013-02-21 09:00:00"
    end_time "2013-02-21 12:00:00"
    association :time_type, factory: :time_type_work
  end
end
