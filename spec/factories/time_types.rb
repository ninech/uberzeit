# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :time_type do
    sequence(:name) { |n| "time_type#{n}" }
    is_work false
    is_vacation false
    bonus_factor 0.0
    exclude_from_calculation false

    factory :time_type_work do
      is_work true
    end

    factory :time_type_onduty do
      is_work true
    end

    factory :time_type_vacation do
      is_vacation true
    end

    factory :time_type_compensation do
      exclude_from_calculation true
    end

    factory :time_type_paid_absence do
    end

    factory :invalid_time_type do
      name nil
    end
  end
end
