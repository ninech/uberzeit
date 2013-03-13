# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :recurring_schedule do
    ends "never"
    ends_counter 1
    ends_date "2013-03-12"
    repeat_interval_type "daily"
    daily_repeat_interval 1
    weekly_repeat_interval 1
    weekly_repeat_weekday "MyString"
    monthly_repeat_interval 1
    monthly_repeat_by "MyString"
    yearly_repeat_interval 1
  end
end
