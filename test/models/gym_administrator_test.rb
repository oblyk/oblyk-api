# frozen_string_literal: true

require 'test_helper'

class GymAdministratorTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @gym_administrator = gym_administrators(:gym_administrator_one)
  end

  test 'gym_administrator is valid' do
    assert @gym_administrator.valid?
  end

  test 'gym_administrator is invalid with bad email' do
    @gym_administrator.requested_email = 'bad-email'
    assert_not @gym_administrator.valid?
  end

  test 'gym_administrator is invalid with wrong roles' do
    @gym_administrator.roles = ['wrong_role']
    assert_not @gym_administrator.valid?
  end

  test 'setting gym as administered after create' do
    gym = gyms(:my_gym)
    gym.update_column(:assigned_at, nil)
    assert_not gym.administered?
    
    GymAdministrator.create(
      user: users(:normal_user),
      gym: gym,
      roles: [GymRole::MANAGE_GYM],
      requested_email: 'new-admin@example.com'
    )
    
    assert gym.reload.assigned_at.present?
  end

  test 'summary_to_json returns expected keys' do
    json = @gym_administrator.summary_to_json
    assert_equal @gym_administrator.id, json[:id]
    assert_equal @gym_administrator.roles, json[:roles]
    assert_includes json.keys, :user
  end

  test 'detail_to_json returns gym information' do
    json = @gym_administrator.detail_to_json
    assert_includes json.keys, :gym
    assert_equal @gym_administrator.gym.id, json[:gym][:id]
  end

  test 'send_invitation_email! enqueues an email' do
    assert_enqueued_emails 1 do
      @gym_administrator.send_invitation_email!('http://localhost:3000')
    end
  end
end
