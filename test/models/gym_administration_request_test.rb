# frozen_string_literal: true

require 'test_helper'

class GymAdministrationRequestTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @request = gym_administration_requests(:gym_administration_request_one)
  end

  test 'gym_administration_request is valid' do
    assert @request.valid?
  end

  test 'gym_administration_request is invalid without first_name' do
    @request.first_name = nil
    assert_not @request.valid?
  end

  test 'gym_administration_request is invalid with bad email' do
    @request.email = 'bad-email'
    assert_not @request.valid?
  end

  test 'accept! creates a GymAdministrator' do
    assert_difference 'GymAdministrator.count', 1 do
      @request.accept!
    end

    administrator = GymAdministrator.last
    assert_equal @request.user_id, administrator.user_id
    assert_equal @request.gym_id, administrator.gym_id
    assert_equal GymRole::LIST, administrator.roles
  end

  test 'deal returns true if gym is administered' do
    @request.gym.administered!
    assert @request.deal
  end

  test 'summary_to_json returns expected keys' do
    json = @request.summary_to_json
    assert_equal @request.id, json[:id]
    assert_equal @request.justification, json[:justification]
    assert_includes json.keys, :gym
    assert_includes json.keys, :user
    assert_includes json.keys, :deal
  end

  test 'sending email notification after create' do
    assert_enqueued_emails 2 do
      GymAdministrationRequest.create(
        user: users(:normal_user),
        gym: gyms(:my_gym),
        first_name: 'Test',
        last_name: 'User',
        email: 'test@example.com',
        justification: 'Justification test'
      )
    end
  end
end
