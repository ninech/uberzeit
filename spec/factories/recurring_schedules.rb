# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :recurring_schedule do
    ignore do
      exception_dates []
    end

    enterable { FactoryGirl.build(:absence) }
    ends 'counter'
    ends_counter 100
    ends_date Date.today
    weekly_repeat_interval 1
    active false

    factory :active_recurring_schedule do
      active true
    end

    after(:build) do |recurring_schedule, evaluator|
      evaluator.exception_dates.each do |exception_date|
        recurring_schedule.exception_dates.build(date: exception_date)
      end
    end
  end
end
