FactoryGirl.define do
  factory :team do |f|
    name { Faker::Company.bs }

    ignore do
      leaders_count 0
      users_count 0
    end

    after(:create) do |team, evaluator|
      FactoryGirl.create_list(:user, evaluator.users_count, teams: [team])
      FactoryGirl.create_list(:team_leader, evaluator.leaders_count, teams: [team])
    end
  end
end

