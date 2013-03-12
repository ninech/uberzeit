# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :time_type do
    sequence(:name) { |n| "time_type#{n}" }
    is_work false
    is_vacation false

    factory :time_type_work do
      is_work true
    end

    factory :time_type_vacation do
      is_vacation true
      daywise true
    end

    factory :time_type_break do
      # no flags set
    end

    factory :invalid_time_type do
      name nil
    end

  end

end
