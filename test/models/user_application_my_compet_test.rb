# frozen_string_literal: true

require 'test_helper'

class UserApplicationMyCompetTest < ActiveSupport::TestCase
  setup do
    @user = users(:super_admin_user)
    @my_compet_app = UserApplicationMyCompet.new(
      user: @user,
      ffme_licence_number: '123456'
    )
  end

  test 'should be valid' do
    assert @my_compet_app.valid?
  end

  test 'ffme_licence_number should be present' do
    @my_compet_app.ffme_licence_number = nil
    assert_not @my_compet_app.valid?
  end

  test 'ffme_licence_number should be numerical' do
    @my_compet_app.ffme_licence_number = 'abc'
    assert_not @my_compet_app.valid?
  end

  test 'ffme_licence_number should be normalised' do
    @my_compet_app.ffme_licence_number = ' 123456 '
    @my_compet_app.valid?
    assert_equal '123456', @my_compet_app.ffme_licence_number
  end

  test 'ffme_licence_number should be nil if blank' do
    @my_compet_app.ffme_licence_number = '  '
    @my_compet_app.valid?
    assert_nil @my_compet_app.ffme_licence_number
  end
end
