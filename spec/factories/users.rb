FactoryGirl.define do
  factory :user do |f|
    name { Faker::Name.name }

    factory :leader do
      after(:create) { |user| FactoryGirl.create(:team).leaders << user }
    end
  end
end