# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :customer do
    sequence(:number)
    name "Yolo Inc."
    abbreviation 'yolo'
  end
end
