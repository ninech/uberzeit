# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :recurring_schedule do
    enterable { FactoryGirl.build(:date_entry) }
    ends 'never'
    ends_counter 1
    ends_date Date.today
    repeat_interval_type 'daily'

    daily_repeat_interval 1
    weekly_repeat_interval 1
    monthly_repeat_interval 1
    yearly_repeat_interval 1

    monthly_repeat_by 'day_of_month'
  end
end
