FactoryGirl.define do
  factory :team do |f|
    name {Faker::Company.bs}

    ignore do
      leaders_count 1
      members_count 3
    end

    after(:create) do |team, evaluator|
      team.leaders += FactoryGirl.create_list(:user, evaluator.leaders_count)
      team.members += FactoryGirl.create_list(:user, evaluator.members_count)
    end
  end
end

