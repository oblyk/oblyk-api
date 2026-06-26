# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.8'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '6.0.6.1'
# Pin concurrent-ruby < 1.3.0 (1.3.0+ breaks ActiveSupport 6.0.x LoggerThreadSafeLevel)
gem 'concurrent-ruby', '1.3.4'
# Use sqlite3 as the database for Active Record
gem 'mysql2'
# Use Puma as the app server
gem 'puma'
# Use Redis adapter to run Action Cable in production
gem 'redis'
# Redis gem for cache
gem 'hiredis'
# Use Active Model has_secure_password
gem 'bcrypt'
# provides a full set of stores (Cache, Session, HTTP Cache) for Ruby on Rails
gem 'redis-rails'
# Adds a Redis::Namespace class which can be used to namespace Redis keys
gem 'redis-namespace'

# Use Active Storage variant
gem 'image_processing', '~> 1.14'

# Convert Video (from .mov to .mp4 by example)
gem 'streamio-ffmpeg'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'jwt'
gem 'rack-cors'

# Addressable is an alternative implementation to the URI implementation
gem 'addressable'

# Active storage validation
gem 'activestorage-validator'

# Analyze image
gem 'mini_magick'

# Analyze user agent
gem 'useragent'

# Pagination
gem 'kaminari'

# Sidekiq
gem 'sidekiq', '~> 6'

# Track changes
gem 'paper_trail'

# Simple Rest Client
gem 'rest-client'

# Monitoring rails performance with RoR vs Wild
gem 'rorvswild'

# Gem for export to csv
gem 'csv'

# Gem for markdown
gem 'redcarpet'

# Sitemap gem
gem 'sitemap_generator'

# Dalli for memcached
gem 'dalli'

# Levenshtein in C
gem 'levenshtein-ffi', require: 'levenshtein'

# Brevo email sdk
gem 'brevo'

# Generate PDF from html
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

# Generate circular chart PDFs
gem 'prawn'
gem 'prawn-svg', '0.34.2'

# Generate QrCode
gem 'rqrcode', '~> 2.0'

# Google Cloud storage
gem 'google-cloud-storage', require: false

# Aws sdk s3 for Cloudflare R2 object storage
gem 'aws-sdk-s3', '1.142.0'

# A fast JSON parser and Object marshaller as a Ruby gem.
gem 'oj'

# Zip gen
gem 'rubyzip'

# Manage money with rails
gem 'money-rails'

# Stripe (payment webhook)
gem 'stripe'

# JSON API serializer https://github.com/jsonapi-serializer/jsonapi-serializer
gem 'jsonapi-serializer'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  # Ruby static code analyzer
  gem 'rubocop'
  gem 'rubocop-faker'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  # Small gem which causes rails console to open pry
  gem 'pry-doc'
  gem 'pry-rails'
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
  gem 'capistrano-sidekiq', '>= 3.0'
  # Deployment whit ed25519
  gem 'bcrypt_pbkdf'
  gem 'ed25519'

  # Bundler leak memory
  gem 'bundler-leak'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Test coverage : https://github.com/simplecov-ruby/simplecov
  gem 'simplecov', require: false
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end
