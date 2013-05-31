namespace :uberzeit do

  namespace :sync do

    desc 'Synchronize the configured ldap service'
    task :ldap => :environment do
      LdapSync.all
    end

  end

end
