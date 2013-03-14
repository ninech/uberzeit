# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :timer do
    time_sheet nil
    time_type nil
    start_time "2013-03-13 15:41:10"
  end
end
