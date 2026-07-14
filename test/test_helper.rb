# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'rails' do
  skip '/lib'

  group 'Controllers', 'app/controllers'
  group 'Helpers',     'app/helpers'
  group 'Jobs',        'app/jobs'
  group 'Mailers',     'app/mailers'
  group 'Models',      'app/models'
  group 'Serializers', 'app/serializers'
  group 'Services',    'app/services'
end

ENV['RAILS_ENV'] ||= 'test'
ENV['SEND_EMAIL_WITH'] = 'smtp'
ENV['MY_COMPET_TOKEN'] = 'oblyk-test-token'
ENV['APP_URL'] = 'http://localhost:3000'

require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/autorun'
require 'support/auth_helpers'

module ActiveSupport
  class TestCase
    include AuthHelper

    # Run tests in parallel with specified workers
    number_of_processors = ENV.fetch('TEST_NUMBER_OF_PROCESSORS', 5)
    parallelize(workers: number_of_processors)

    parallelize_setup do |worker|
      SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}"
    end

    parallelize_teardown do |_worker|
      SimpleCov.result
    end

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all
  end
end
