# frozen_string_literal: true

require 'test_helper'

module Api
  module Embedded
    class EmbeddedControllerTest < ActionDispatch::IntegrationTest
      test 'should inherit from ApplicationController' do
        assert_operator EmbeddedController, :<, ApplicationController
      end
    end
  end
end
