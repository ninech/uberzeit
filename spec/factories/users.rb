FactoryGirl.define do
  factory :user do |f|
    sequence(:name) { |n| "user#{n}" }
    time_zone { Time.zone.name }

    ignore do
      with_employment true
      with_sheet true
    end

    after(:create) { |user, evaluator| user.employments << FactoryGirl.create(:employment, user: user, start_date: '2013-01-01', end_date: '2013-12-31') if evaluator.with_employment && user.employments.empty? }
    after(:create) { |user, evaluator| user.time_sheets << FactoryGirl.create(:time_sheet, user: user) if evaluator.with_sheet && user.time_sheets.empty? }

    factory :admin do
      after(:create) { |user| user.add_role(:admin) }
    end
  end

end
