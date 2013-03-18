# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :recurring_schedule do
    enterable { FactoryGirl.build(:date_entry) }
    ends 'counter'
    ends_counter 100
    ends_date Date.today
    weekly_repeat_interval 1
  end
end
