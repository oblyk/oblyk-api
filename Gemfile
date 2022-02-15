# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.3'
# Use sqlite3 as the database for Active Record
gem 'mysql2', '>= 0.4.4', '< 0.6.0'
# Use Puma as the app server
gem 'puma', '~> 4.1'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.1.2'
# Redis gem for cache
gem 'hiredis'
# Use Active Model has_secure_password
gem 'bcrypt', '~> 3.1.7'
# provides a full set of stores (Cache, Session, HTTP Cache) for Ruby on Rails
gem 'redis-rails'
# Adds a Redis::Namespace class which can be used to namespace Redis keys
gem 'redis-namespace'

# Use Active Storage variant
gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'jwt'
gem 'rack-cors'

# Addressable is an alternative implementation to the URI implementation
gem 'addressable'

# Active storage validation
gem 'activestorage-validator', '~> 0.1.3'

# Analyze image
gem 'mini_magick'

# Analyze user agent
gem 'useragent'

# Pagination
gem 'kaminari'

# Sidekiq
gem 'sidekiq'
gem 'sidekiq-statistic', '~> 1.4'

# Track changes
gem 'paper_trail', '~> 11.1'

# Rollbar for track errors
gem 'rollbar'

# Simple Rest Client
gem 'rest-client'

# Monitoring rails performance with RoR vs Wild
gem 'rorvswild'

# Gem for test and documentation API
gem 'rspec_api_documentation'
gem 'apitome', github: 'jejacks0n/apitome'

# Gem for export to csv
gem 'csv'

# Gem for markdown
gem 'redcarpet'

# Sitemap gem
gem 'sitemap_generator'

# Dalli for memcached
gem 'dalli'

group :development, :test do
  # Ruby static code analyzer
  gem 'rubocop-faker'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  # Small gem which causes rails console to open pry
  gem 'pry-doc'
  gem 'pry-rails'
  gem 'database_cleaner'
  gem 'rspec-rails', '~> 5.0.0'
  gem 'faker'
  gem 'factory_bot_rails'
end

group :development do
  gem 'listen', '~> 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Open mail in browser rather than send real email
  gem 'letter_opener'

  # Capistrano
  gem 'capistrano'
  gem 'capistrano3-puma'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  gem 'capistrano-sidekiq'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
