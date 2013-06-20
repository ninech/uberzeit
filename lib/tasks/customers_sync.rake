namespace :uberzeit do
  namespace :sync do

    desc 'Synchronize customers via CustomerPlugin'
    task :customers => :environment do
      CustomerSync.new.sync
    end
  end
end
