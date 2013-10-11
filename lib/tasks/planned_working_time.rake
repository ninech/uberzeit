namespace :uberzeit do

  namespace :generate do

    desc 'Creates all the planned working time entries for each user for the current and next year'
    task :planned_working_time => :environment do
      GeneratePlannedWorkingTimeTask.new.run
    end

  end

end

