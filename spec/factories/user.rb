FactoryGirl.define do
  factory :user do |f|
    name { Faker::Name.name }

    factory :leader do |f|
      after(:create) do |user|
        FactoryGirl.create(:team).leaders << user
      end
    end
  end

end