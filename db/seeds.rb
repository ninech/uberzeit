# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if TimeType.count == 0
  TimeType.create(name: 'Work', is_work: true, is_vacation: false, color_index: 10, icon: :briefcase)
  TimeType.create(name: 'On Duty', is_work: true, is_vacation: false, bonus_factor: 0.1, color_index: 11, icon: :road)
  TimeType.create(name: 'Vacation', is_work: false, is_vacation: true, color_index: 1, icon: :plane)
  TimeType.create(name: 'Illness', is_work: false, is_vacation: false, color_index: 2, icon: :medkit)
  TimeType.create(name: 'Compensation', is_work: false, is_vacation: false, exclude_from_calculation: true, color_index: 7, icon: :'circle-blank')
  TimeType.create(name: 'Absence by law', is_work: false, is_vacation: false, color_index: 8, icon: :legal)
end

if ActivityType.count == 0
  ActivityType.create(name: 'Maintenance')
  ActivityType.create(name: 'Setup Server')
end
