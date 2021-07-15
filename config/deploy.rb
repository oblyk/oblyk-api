# frozen_string_literal: true

lock '3.16.0'

set :application, 'oblyk-api'
set :repo_url, 'git@github.com:oblyk/oblyk-api.git'

# Shared directories
set :linked_dirs, fetch(:linked_dirs, []).push(
  'log',
  'tmp/pids',
  'tmp/cache',
  'tmp/sockets',
  'vendor/bundle',
  '.bundle',
  'public/system',
  'public/uploads',
  'uploads',
  'lib/certs',
  'storage'
)

# Shared files
set :linked_files, fetch(:linked_files, []).push(
  'config/database.yml',
  'config/master.key',
  'config/credentials.yml.enc',
  'config/local_env.yml'
)

set :puma_role, :web

set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"

set :assets_roles, []

set :keep_releases, 5
