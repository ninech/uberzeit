# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :time_type do
    sequence(:name) { |n| "time_type#{n}" }
    is_work false
    is_vacation false
    absence false
    calculation_factor 1.0

    factory :time_type_work do
      is_work true
    end

    factory :time_type_vacation do
      is_vacation true
      absence true
    end

    factory :time_type_onduty do
    end

    factory :time_type_break do
      calculation_factor 0
    end

    factory :time_type_paid_absence do
      absence true
    end

    factory :invalid_time_type do
      name nil
    end
  end
end
