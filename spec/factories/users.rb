FactoryGirl.define do
  factory :user do |f|
    sequence(:name) { |n| "user#{n}" }
    time_zone { Time.zone.name }
    
    after(:create) { |user| user.employments << FactoryGirl.create(:employment, user: user) } 
    after(:create) { |user| user.sheets << FactoryGirl.create(:time_sheet, user: user) } 

    factory :leader do
      after(:create) { |user| FactoryGirl.create(:team).leaders << user }
    end
  end

end