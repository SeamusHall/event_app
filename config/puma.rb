require 'fileutils' # used to create directories

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

# Change to match your CPU core count
workers 2 # 4 or 8 ;)

# Min and Max threads per worker
threads 8, 32 # Only because the server can handle it ;)

port ENV.fetch("PORT") { 3000 }

app_dir = File.expand_path("../..", __FILE__)
shared_dir = "#{app_dir}/shared"

# Default to development
rails_env = ENV['RAILS_ENV'] || "development"
environment rails_env

# Set up socket location
FileUtils.mkdir_p "#{shared_dir}/sockets" # create socket directory
bind "unix://#{shared_dir}/sockets/puma.sock"

# Logging
FileUtils.mkdir_p "#{shared_dir}/log" # create log directory
stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true

# Set master PID and state locations
FileUtils.mkdir_p "#{shared_dir}/pids" # create process ids directory
pidfile "#{shared_dir}/pids/puma.pid"
state_path "#{shared_dir}/pids/puma.state"
activate_control_app

on_worker_boot do
  require "active_record"
  ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
  ActiveRecord::Base.establish_connection(YAML.load_file("#{app_dir}/config/database.yml")[rails_env])
end

before_fork do
  require 'puma_worker_killer'

  PumaWorkerKiller.enable_rolling_restart(12 * 3600) # 12 hours in seconds
end
