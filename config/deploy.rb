
server '131.230.116.221', port: 22, roles: [:web, :app, :db], primary: true

app_dir = File.expand_path("../..", __FILE__)
shared_dir = "#{app_dir}/shared"

set :repo_url,        'git@github.com:UniversityHousing/events.git'
set :application,     'events'
set :user,            'deployer'
set :puma_threads,    [8, 32]
set :puma_workers,    2      # Server can handle it

set :pty,             true
set :use_sudo,        false
set :stage,           :production
set :deploy_via,      :remote_cache
set :deploy_to,       "/var/www/#{fetch(:application)}"
set :puma_bind,       "unix://#{shared_dir}/sockets/puma.sock"
set :puma_state,      "#{shared_dir}/pids/puma.state"
set :puma_pid,        "#{shared_dir}/pids/puma.pid"
set :puma_access_log, "#{shared_dir}/log/puma.stderr.log"
set :puma_error_log,  "#{shared_dir}/log/puma.stdout.log"
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }
set :puma_preload_app, true
set :puma_worker_timeout, 4 * 3600      # 4 hours in seconds
set :puma_init_active_record, true  # Change to false when not using ActiveRecord

## Defaults:
#set :scm,           :git
set :branch,        :master
set :format,        :pretty
set :log_level,     :debug
# set :keep_releases, 5

## Linked Files & Directories (Default None):
set :linked_files, %w{config/database.yml config/environments/production config/puma.rb config/authorize_net.yml config/secrets.yml}
set :linked_dirs,  %w{bin log shared tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads}

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_dir} -p"
      execute "mkdir #{shared_dir}/sockets -p"
      execute "mkdir #{shared_dir}/pids -p"
      execute "mkdir #{shared_dir}/log -p"

    end
  end

  before :start, :make_dirs
end

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/master"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  before :starting,     :check_revision
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  after  :finishing,    :restart
end
