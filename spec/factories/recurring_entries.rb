# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :recurring_entry do
    time_sheet nil
    time_type nil
    schedule_hash "MyText"
  end
end
