
server '131.230.116.221', port: 22, roles: [:web, :app, :db], primary: true

set :repo_url,        'git@github.com:UniversityHousing/events.git'
set :application,     'events'
set :user,            'deployer'
set :puma_threads,    [8, 32]
set :puma_workers,    2      # Server can handle it

set :pty,             true
set :use_sudo,        false
set :stage,           :production
set :deploy_via,      :remote_cache
set :deploy_to,       "/var/www/events"
set :puma_bind,       "unix:///var/www/events/shared/tmp/sockets/events-puma.sock"
set :puma_state,      "/var/www/events/shared/tmp/pids/puma.state"
set :puma_pid,        "/var/www/events/shared/tmp/pids/puma.pid"
set :puma_access_log, "/var/www/events/log/puma.error.log"
set :puma_error_log,  "/var/www/events/log/puma.access.log"
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }
set :puma_preload_app, true
set :puma_worker_timeout, 4 * 3600      # 4 hours in seconds
set :puma_init_active_record, true  # Change to false when not using ActiveRecord

## Defaults:
set :repository, "deployer@131.230.116.221:/var/www/events"
set :scm,           :git
set :branch,        :master
set :format,        :pretty
set :log_level,     :debug
# set :keep_releases, 5

## Linked Files & Directories (Default None):
set :linked_files, %w{config/database.yml}
set :linked_dirs,  %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads}

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir /var/www/events/shared/ -p"
      execute "mkdir /var/www/events/shared/tmp/sockets -p"
      execute "mkdir /var/www/events/shared/tmp/pids -p"
      execute "mkdir /var/www/events/current/public -p"
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
      execute 'sudo service nginx restart'
    end
  end

  before :starting,     :check_revision
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  after  :finishing,    :restart
end
