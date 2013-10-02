# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :absence_schedule do
    absence { FactoryGirl.build(:absence) }
    ends_date { Date.today }
    weekly_repeat_interval 1
    active false

    trait :active do
      active true
    end
  end
end
