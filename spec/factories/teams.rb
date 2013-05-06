FactoryGirl.define do
  factory :team do |f|
    name {Faker::Company.bs}

    ignore do
      leaders_count 1
      members_count 3
    end

    after(:create) do |team, evaluator|
      team.members += FactoryGirl.create_list(:user, evaluator.members_count)

      evaluator.leaders_count.times do
        user = FactoryGirl.create(:user)
        user.add_role(:team_leader, team)
        team.members << user
      end
    end
  end
end

