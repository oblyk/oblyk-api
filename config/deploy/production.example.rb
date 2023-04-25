# frozen_string_literal: true

server 'server-ip', user: 'user', roles: %w[app web db], port: 1622

set :deploy_to, '/path/to/app'
set :rails_env, 'production'

# Deploy with master branch
set :branch, 'master'
