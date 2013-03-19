# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :time_type do
    sequence(:name) { |n| "time_type#{n}" }
    is_work false
    is_vacation false
    treat_as_working_time false
    daywise true
    timewise true

    factory :time_type_work do
      is_work true
      treat_as_working_time true
    end

    factory :time_type_vacation do
      treat_as_working_time true
      is_vacation true
      daywise true
    end

    factory :time_type_break do
      # no flags set
    end

    factory :time_type_paid_absence do
      treat_as_working_time true
    end

    factory :invalid_time_type do
      name nil
    end

  end

end
