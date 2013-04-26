FactoryGirl.define do
  factory :time_sheet do
    association :user, with_sheet: false
  end
end
