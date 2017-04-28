source 'https://rubygems.org'

ruby '2.4.1'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.0.2'
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

gem 'haml-rails'
# gem 'pandoc-ruby' # markdown
gem 'kaminari'
gem 'gravtastic'

# For image Uploading
gem 'carrierwave'
gem "mini_magick"

gem 'momentjs-rails', '>= 2.9.0'
gem 'bootstrap3-datetimepicker-rails', '~> 4.17.47'

gem 'sqlite3'

gem 'devise', '~> 4.2'
gem 'cancancan', '~> 1.10'
gem 'responders'
gem 'paranoia', '~> 2.2'

gem 'authorizenet', '1.9.1'
gem "recaptcha", require: "recaptcha/rails"

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# For Running Back Ground Jobs and Implementation of Multithreaded Processing (Later)
# Remember these!!!!
gem 'redis'
gem 'redis-namespace'
gem 'redis-rails'
gem 'redis-rack-cache'
gem 'concurrent-ruby', require: 'concurrent'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

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
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
