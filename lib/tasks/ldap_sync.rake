namespace :uberzeit do

  namespace :sync do

    desc 'Synchronize the configured ldap service'
    task :ldap => :environment do
      User.all.each do |user|
        puts "Synchronizing #{user.uid}"
        LdapSync.sync_person(user.uid)
      end
    end

  end

end
