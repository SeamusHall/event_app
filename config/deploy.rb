
server '131.230.116.221', port: 22, roles: [:web, :app, :db], primary: true

set :repo_url,        'git@github.com:UniversityHousing/events.git'
set :application,     'events'
set :user,            'deployer'
set :puma_threads,    [8, 8]
set :puma_workers,    2      # Server can handle it

set :pty,             true
set :use_sudo,        false
set :stage,           :production
set :deploy_via,      :remote_cache
set :deploy_to,       "/var/www/#{fetch(:application)}"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }
set :puma_preload_app, true
set :puma_worker_timeout, 4 * 3600 # 4 hours in seconds
set :puma_init_active_record, true  # Change to false when not using ActiveRecord

## Defaults:
set :branch,        :master
set :format,        :pretty
set :log_level,     :debug
set :keep_releases, 3 # should only keep the previous 2 release versions
set :migration_role, :db # Defaults to :db role
set :migration_servers, -> { primary(fetch(:migration_role)) } # Defaults to the primary :db server
set :conditionally_migrate, true # Skip migration if files in db/migrate were not modified
set :assets_roles, [:web, :app] # Defaults to [:web]
set :rails_assets_groups, :assets # RAILS_GROUPS env value for the assets:precompile task. Default to nil.
set :keep_assets, 2 # set this to the number of versions to keep

set :linked_dirs, %w(public/uploads public/assets log)

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
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
      invoke 'deploy'
    end
  end

  before :starting,     :check_revision
  after  :finishing,    :compile_assets
  after  :finishing,    :migrate
  after  :finishing,    :cleanup
end
