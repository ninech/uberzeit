# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if TimeType.count == 0
  TimeType.create(name: 'Work', is_work: true, is_vacation: false, color_index: 10, icon: :briefcase)
  TimeType.create(name: 'Vacation', is_work: false, is_vacation: true, color_index: 1, icon: :plane)
  TimeType.create(name: 'Illness', is_work: false, is_vacation: false, color_index: 2, icon: :medkit)
end

if User.count == 0
  u = User.new(email: 'admin@example.org', name: 'McAdmin', given_name: 'John', password: 'admin', password_confirmation: 'admin')
  u.ensure_authentication_token
  u.save(validate: false)
  u.add_role(:admin)
end

Setting.work_per_day_hours = 8.5
Setting.vacation_per_year_days = 25
