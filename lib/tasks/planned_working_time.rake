require 'benchmark'

namespace :uberzeit do

  namespace :generate do

    desc 'Creates all the planned working time entries for each user for the current and next year'
    task :planned_working_time => :environment do
      current_year = Time.now.year
      [current_year, current_year + 1].each do |year|
        User.all.each do |user|
          Rails.logger.info ":generate:planned_working_time Calculating year #{year} for user #{user.uid}"
          user.calculate_planned_working_time!(year)
        end
      end
    end

  end

end

