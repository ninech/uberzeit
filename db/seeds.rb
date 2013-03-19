# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if TimeType.count == 0
  TimeType.create(name: 'Work', is_work: true, is_vacation: false, treat_as_working_time: true, daywise: false, timewise: true)
  TimeType.create(name: 'On Duty', is_work: true, is_vacation: false, treat_as_working_time: true, daywise: false, timewise: true)
  TimeType.create(name: 'Vacation', is_work: false, is_vacation: true, treat_as_working_time: true, daywise: true, timewise: false)
  TimeType.create(name: 'Illness', is_work: false, is_vacation: false, treat_as_working_time: true, daywise: true, timewise: true)
  TimeType.create(name: 'Compensation', is_work: false, is_vacation: false, treat_as_working_time: false, daywise: true, timewise: true)
  TimeType.create(name: 'Absence by law', is_work: false, is_vacation: false, treat_as_working_time: false, daywise: true, timewise: false)
end
