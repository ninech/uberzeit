# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :time_type do
    name 'Break'
    is_work false
    is_vacation false
    is_onduty false

    factory :time_type_work do
      name 'Work'
      is_work true
    end

    factory :time_type_vacation do
      name 'Vacation'
      is_vacation true
    end

    factory :time_type_onduty do
      name 'On Duty'
      is_onduty true
    end
  end
end
