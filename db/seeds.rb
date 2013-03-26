# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if TimeType.count == 0
  TimeType.create(name: 'Work', is_work: true, is_vacation: false, absence: false)
  TimeType.create(name: 'On Duty', is_work: true, is_vacation: false, calculation_factor: 1.1, absence: false)
  TimeType.create(name: 'Vacation', is_work: false, is_vacation: true, absence: true)
  TimeType.create(name: 'Illness', is_work: false, is_vacation: false, absence: true)
  TimeType.create(name: 'Compensation', is_work: false, is_vacation: false, calculation_factor: 0.0, absence: true)
  TimeType.create(name: 'Absence by law', is_work: false, is_vacation: false, absence: true)
end
