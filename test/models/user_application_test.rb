# frozen_string_literal: true

require 'test_helper'

class UserApplicationTest < ActiveSupport::TestCase
  setup do
    @user = users(:normal_user)
    @user_application = user_applications(:my_compet_app)
  end

  test 'should be valid' do
    assert @user_application.valid?
  end

  test 'should have a user' do
    @user_application.user = nil
    assert_not @user_application.valid?
  end

  test 'should set user_application_id before validation' do
    new_app = UserApplication.new(user: users(:super_admin_user), type: 'UserApplicationMyCompet')
    new_app.send(:set_user_application_id)
    assert_not_nil new_app.user_application_id
  end

  test 'user should have unique application per type' do
    duplicate_app = @user_application.dup
    assert_not duplicate_app.valid?
  end

  test 'summary_to_json should return correct data' do
    summary = @user_application.summary_to_json
    assert_equal @user_application.id, summary[:id]
    assert_equal 'UserApplicationMyCompet', summary[:type]
    assert_equal 'active', summary[:status]
    assert_equal '123456', summary[:ffme_licence_number]
  end

  test 'detail_to_json should return summary' do
    assert_equal @user_application.summary_to_json, @user_application.detail_to_json
  end
end
