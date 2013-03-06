FactoryGirl.define do
  factory :user do |f|
    sequence(:name) { |n| "user#{n}" }
    time_zone { Time.zone.name }

    ignore do
      with_employment true
      with_sheet true
    end
    
    after(:create) { |user, evaluator| user.employments << FactoryGirl.create(:employment, user: user) if evaluator.with_employment } 
    after(:create) { |user, evaluator| user.time_sheets << FactoryGirl.create(:time_sheet, user: user) if evaluator.with_sheet } 

    factory :leader do
      after(:create) { |user| FactoryGirl.create(:team).leaders << user }
    end

    factory :admin do
      after(:create) { |user| user.add_role(:admin) }
    end
  end

end
