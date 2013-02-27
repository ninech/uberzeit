# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :employment do
    user
    start_date Time.zone.now.beginning_of_year.to_date
    end_date nil
    workload 100

    factory :invalid_employment do
      workload 0
    end
  end
end
