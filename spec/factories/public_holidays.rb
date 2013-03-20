# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :public_holiday do
    start_date "2013-03-18"
    end_date "2013-03-18"
    name "Christmas"
    first_half_day false
    second_half_day false

    factory :invalid_public_holiday do
      name nil
    end
  end
end
