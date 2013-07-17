# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if TimeType.count == 0
  TimeType.create(name: 'Work', is_work: true, is_vacation: false, color_index: 10, icon: :briefcase)
  TimeType.create(name: 'On Duty', is_work: true, is_vacation: false, bonus_calculator: 'nine_on_duty', color_index: 11, icon: :road)
  TimeType.create(name: 'Vacation', is_work: false, is_vacation: true, color_index: 1, icon: :plane)
  TimeType.create(name: 'Illness', is_work: false, is_vacation: false, color_index: 2, icon: :medkit)
  TimeType.create(name: 'Compensation', is_work: false, is_vacation: false, exclude_from_calculation: true, color_index: 7, icon: :'circle-blank')
  TimeType.create(name: 'Absence by law', is_work: false, is_vacation: false, color_index: 8, icon: :legal)
end

if ActivityType.count == 0
  ActivityType.create(name: 'Maintenance')
  ActivityType.create(name: 'Setup Server')
end

if Customer.count == 0
  Customer.create(id: 1, name: 'Yolo Inc')
  Customer.create(id: 2, name: 'Nils\'s Vacuum Cleaners Inc')
end

if Project.count == 0
  Project.create(customer_id: 1, name: 'Mustached Spice')
  Project.create(customer_id: 1, name: 'Overwhelming Matterhorn')

  Project.create(customer_id: 2, name: 'Cleaning with Fun Cluster 1')
  Project.create(customer_id: 2, name: 'Demo @ nine HeadQuarters including an apero')
end
