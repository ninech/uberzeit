FactoryGirl.define do
  factory :user do |f|
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:given_name) { |n| "given_name#{n}" }
    sequence(:name) { |n| "name#{n}" }
    password "hans-im-glueck"
    password_confirmation "hans-im-glueck"
    active true

    teams { FactoryGirl.create_list(:team, 1) }

    ignore do
      with_employment true
    end

    after(:create) { |user, evaluator| user.employments << FactoryGirl.create(:employment, user: user, start_date: '2013-01-01', end_date: '2013-12-31') if evaluator.with_employment && user.employments.empty? }

    factory :admin do
      after(:create) { |user| user.add_role(:admin) }
    end

    factory :accountant do
      after(:create) { |user| user.add_role(:accountant) }
    end

    factory :team_leader do
      after(:create) { |user| user.teams.each { |team| user.add_role(:team_leader, team) } }
    end
  end

end
