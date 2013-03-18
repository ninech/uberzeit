# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :exception_date do
    recurring_schedule nil
    date "2013-03-18"
  end
end
