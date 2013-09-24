# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :adjustment do
    user
    time_type
    date "2013-05-27"
    duration 1
    label "test"

    factory :invalid_adjustment do
      date "invalid-date"
    end
  end
end
