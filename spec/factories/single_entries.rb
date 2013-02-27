# Read about factories at https://github.com/thoughtbot/factory_girl
def time_rand from = 0.0, to = Time.now
  from = from.midnight if from.kind_of?(Date)
  to = to.midnight if to.kind_of?(Date)
  Time.at(from + rand * (to.to_f - from.to_f))
end

FactoryGirl.define do
  factory :single_entry do

    ignore do
      duration UberZeit::Config[:work_per_day]
      range { (Time.zone.today.at_beginning_of_week..Time.zone.today.next_week) }
      type :work
      start nil
    end

    time_sheet 
    start_time { start.nil? ? time_rand(range.min, range.max) : start }
    end_time  { start_time + duration }
    association :time_type, factory: :time_type_work

    after(:create) do |entry, evaluator|
      entry.time_type = FactoryGirl.create("time_type_#{evaluator.type}")   
    end

    factory :invalid_single_entry do
      end_time { start_time }
    end

   end
end
