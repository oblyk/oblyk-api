# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/lib'

  add_group 'Controllers', 'app/controllers'
  add_group 'Helpers',     'app/helpers'
  add_group 'Jobs',        'app/jobs'
  add_group 'Mailers',     'app/mailers'
  add_group 'Models',      'app/models'
  add_group 'Serializers', 'app/serializers'
  add_group 'Services',    'app/services'
  add_group 'Workers',     'app/worker'
end

ENV['RAILS_ENV'] ||= 'test'
ENV['SEND_EMAIL_WITH'] = 'smtp'

require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/autorun'
require 'minitest/mock'
require 'support/auth_helpers'

module ActiveSupport
  class TestCase
    include AuthHelper

    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    parallelize_setup do |worker|
      SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}"
    end

    parallelize_teardown do |_worker|
      SimpleCov.result
    end

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
