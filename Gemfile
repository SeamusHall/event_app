source 'https://rubygems.org'

ruby '2.4.1'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.0.2'

# Deployment Gems
gem 'puma', '~> 3.0'
gem 'puma_worker_killer'

gem 'uglifier', '>= 1.3.0'
gem 'sass-rails', '~> 5.0'
gem 'bootstrap-sass', '~> 3.3.7'

gem 'jquery-rails'
gem 'coffee-rails', '~> 4.2'
gem 'turbolinks', '~> 5'
gem 'jquery-turbolinks'
gem 'jbuilder', '~> 2.5'
gem 'nested_form'

# User Account Creation
gem 'country_select'
gem 'validates_zipcode'
gem 'phonelib'
gem 'geocoder'

gem 'haml-rails'
# gem 'pandoc-ruby' # markdown
gem 'kaminari'
gem 'gravtastic'
gem 'ckeditor'

# For image and Video Uploading
gem 'carrierwave'
gem "mini_magick"
gem 'videojs_rails'

# For slider system
gem 'bxslider', github: 'EasyIP2023/bxslider'

gem 'momentjs-rails', '>= 2.9.0'
gem 'bootstrap3-datetimepicker-rails', '~> 4.17.47'

gem 'sqlite3'

gem 'devise', '~> 4.2'
gem 'cancancan', '~> 1.10'
gem 'responders'
gem 'paranoia', '~> 2.2'

gem 'authorizenet', '1.9.1'
gem "recaptcha", require: "recaptcha/rails"

# For Running Back Ground Jobs and Implementation of Multithreaded Processing (Later)
gem 'redis'
gem 'redis-namespace'
gem 'redis-rails'
gem 'redis-rack-cache'
gem 'sidekiq'
gem 'sinatra', github: 'sinatra/sinatra'
gem 'concurrent-ruby', require: 'concurrent'

group :production do
  gem 'mysql2', '~> 0.4.5'
end

group :development, :test do
  gem 'byebug', platform: :mri
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'active_record_query_trace'
  gem 'faker'

  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Deployment Gems
  gem 'capistrano',              require: false
  gem 'capistrano-rvm',          require: false
  gem 'capistrano-rails',        require: false
  gem 'capistrano-bundler',      require: false
  gem 'capistrano3-puma',        require: false
  gem 'capistrano-linked-files', require: false
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
