# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :time_type do
    name "MyString"
    is_work false
    is_vacation false
    is_onduty false
  end
end
