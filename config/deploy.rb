set :stages, %w(en zh)
set :default_stage, 'zh'

require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rvm'
require 'mina/puma'
require "mina_sidekiq/tasks"
require 'mina/logs'
require 'mina/multistage'

set :shared_dirs, fetch(:shared_dirs, []).push('log', 'public/uploads', 'public/personal')
set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/application.yml')

set :sidekiq_pid, ->{ "#{fetch(:shared_path)}/tmp/pids/sidekiq.pid" }

task :environment do
  invoke :'rvm:use', '2.3.1'
end

task :setup => :environment do
  command %[mkdir -p "#{fetch(:shared_path)}/tmp/sockets"]
  command %[chmod g+rx,u+rwx "#{fetch(:shared_path)}/tmp/sockets"]

  command %[mkdir -p "#{fetch(:shared_path)}/tmp/pids"]
  command %[chmod g+rx,u+rwx "#{fetch(:shared_path)}/tmp/pids"]

  command %[mkdir -p "#{fetch(:shared_path)}/log"]
  command %[chmod g+rx,u+rwx "#{fetch(:shared_path)}/log"]

  command %[mkdir -p "#{fetch(:shared_path)}/public/uploads"]
  command %[chmod g+rx,u+rwx "#{fetch(:shared_path)}/public/uploads"]

  command %[mkdir -p "#{fetch(:shared_path)}/config"]
  command %[chmod g+rx,u+rwx "#{fetch(:shared_path)}/config"]

  command %[touch "#{fetch(:shared_path)}/config/application.yml"]
  command %[echo "-----> Be sure to edit '#{fetch(:shared_path)}/config/application.yml'"]

  command %[touch "#{fetch(:shared_path)}/config/database.yml"]
  command %[echo "-----> Be sure to edit '#{fetch(:shared_path)}/config/database.yml'"]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  command %[echo "-----> Server: #{fetch(:domain)}"]
  command %[echo "-----> Path: #{fetch(:deploy_to)}"]
  command %[echo "-----> Branch: #{fetch(:branch)}"]

  deploy do
    invoke :'sidekiq:quiet'
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      invoke :'rvm:use', '2.3.1'
      invoke :'puma:hard_restart'
      invoke :'sidekiq:restart'
    end
  end
end

desc "Deploys the current version to the server."
task :first_deploy => :environment do
  command %[echo "-----> Server: #{fetch(:domain)}"]
  command %[echo "-----> Path: #{fetch(:deploy_to)}"]
  command %[echo "-----> Branch: #{fetch(:branch)}"]

  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'deploy:cleanup'

    on :launch do
      invoke :'rvm:use', '2.3.1'
      invoke :'rails:db_create'
    end
  end
end
