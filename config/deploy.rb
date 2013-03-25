require 'bundler/capistrano'
require 'database_yml/capistrano'
require 'airbrake/capistrano'
require 'capistrano/maintenance'

set :application, 'UberZeit'
set :repository, 'git@git.nine.ch:uberzeit.git'
set :scm, :git

set :stages, %w(production staging)
set :default_stage, 'staging'
require 'capistrano/ext/multistage'

ssh_options[:forward_agent] = true
set :use_sudo, false
set :user, 'www-data'

set :deploy_via, :remote_cache
set :default_environment, {
  'PATH' => '$PATH:/home/www-data/.gem/bin',
  'GEM_HOME' => '/home/www-data/.gem'
}

load  'deploy/assets'

desc 'Generate sessions'
task :generate_sessions, :roles => :app do
  run "mkdir -p #{shared_path}/sessions"
end
after 'deploy:setup', :generate_sessions

desc 'Link sessions from shared'
task :generate_tmp_sessions, :roles => :app do
  run "ln -s #{shared_path}/sessions #{release_path}/tmp/sessions"
end
after 'deploy:finalize_update', :generate_tmp_sessions

after 'deploy:restart', 'deploy:cleanup'

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
