# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :employment do
    user
    start_time Time.zone.now.beginning_of_year
    end_time nil
    workload 100
  end
end
