# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if TimeType.count == 0
  TimeType.create(name: 'Biglu', is_work: true)
  TimeType.create(name: 'Ferien', is_vacation: true)
  TimeType.create(name: 'Pikett', is_onduty: true)
  TimeType.create(name: 'Krankfeiern')
end