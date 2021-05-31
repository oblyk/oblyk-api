# frozen_string_literal: true

server 'next.oblyk.org', user: 'lucien', roles: %w[app web db], port: 1622

set :deploy_to, '/var/www/oblyk/api'
set :rails_env, 'production'

# Deploy with master branch
set :branch, 'master'
