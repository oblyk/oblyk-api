# frozen_string_literal: true

lock '3.20.1'

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
  'public/sitemaps',
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
  'config/local_env.yml',
  'config/puma.rb',
  'config/gsc.keyfile.json',
  'public/sitemap.xml',
  'public/sitemap1.xml'
)

set :default_env, 'PATH' => '$HOME/.gem/bin:$PATH', 'GEM_HOME' => '$HOME/.gem', 'GEM_PATH' => '$HOME/.gem'
set :init_system, :systemd

set :puma_role, :web
set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock"

set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"

set :assets_roles, []

set :keep_releases, 5
