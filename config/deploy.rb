require 'bundler/capistrano'
require 'database_yml/capistrano'
require 'airbrake/capistrano'
require 'capistrano/maintenance'

set :application, 'UberZeit'
set :repository, 'git@git.nine.ch:development/uberzeit.git'
set :scm, :git

set :stages, %w(production staging)
set :default_stage, 'staging'
require 'capistrano/ext/multistage'

set :whenever_environment, defer { stage }
set :whenever_command, "bundle exec whenever"
require 'whenever/capistrano'

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

# uberzeit.yml
desc 'Deploy uberzeit.yml file'
task :deploy_uberzeit_yml, :roles => :app do
  template = File.read('config/uberzeit.yml.example')
  put template, "#{shared_path}/config/uberzeit.yml"
end
after 'deploy:setup', :deploy_uberzeit_yml

desc 'Link uberzeit.yml file'
task :link_uberzeit_yml, :roles => :app do
  run "ln -s #{shared_path}/config/uberzeit.yml #{release_path}/config/uberzeit.yml"
end
after 'deploy:finalize_update', :link_uberzeit_yml

after 'deploy:restart', 'deploy:cleanup'

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
