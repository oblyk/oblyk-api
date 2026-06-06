# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:normal_user)
  end

  test 'is valid with valid attributes' do
    user = User.new(
      first_name: 'Jean',
      email: 'jean@test.com',
      password: 'Password123',
      password_confirmation: 'Password123'
    )
    assert user.valid?
  end

  test 'is invalid without first_name' do
    @user.first_name = nil
    assert_not @user.valid?
    assert_not_empty @user.errors[:first_name]
  end

  test 'is invalid without email' do
    @user.email = nil
    assert_not @user.valid?
    assert_not_empty @user.errors[:email]
  end

  test 'is invalid with bad email format' do
    @user.email = 'bad_email'
    assert_not @user.valid?
    assert_not_empty @user.errors[:email]
  end

  test 'is invalid if email is not unique' do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    assert_not duplicate_user.valid?
    assert_not_empty duplicate_user.errors[:email]
  end

  test 'password must follow format' do
    @user.password = 'short'
    @user.password_confirmation = 'short'
    assert_not @user.valid?
    assert_not_empty @user.errors[:password]

    @user.password = 'no_digit_no_upper'
    @user.password_confirmation = 'no_digit_no_upper'
    assert_not @user.valid?
  end

  test 'full_name returns first and last name' do
    @user.first_name = 'Jean'
    @user.last_name = 'Jack'
    assert_equal 'Jean Jack', @user.full_name
  end

  test 'full_name strips whitespace if last name is missing' do
    @user.first_name = 'Jean'
    @user.last_name = nil
    assert_equal 'Jean', @user.full_name
  end

  test 'age calculation' do
    @user.date_of_birth = 20.years.ago.to_date
    assert_equal 20, @user.age
  end

  test 'minor? returns true if under 18' do
    @user.date_of_birth = 17.years.ago.to_date
    assert @user.minor?

    @user.date_of_birth = 19.years.ago.to_date
    assert_not @user.minor?
  end

  test 'initializes slug, uuid and ws_token before validation' do
    user = User.new(first_name: 'New User', email: 'new@user.com', password: 'Password123')
    user.validate
    assert_not_nil user.slug_name
    assert_not_nil user.uuid
    assert_not_nil user.ws_token
  end

  test 'location returns latitude and longitude' do
    @user.latitude = 45.0
    @user.longitude = 5.0
    assert_equal [45.0, 5.0], @user.location
  end

  test 'partner_location returns partner latitude and longitude' do
    @user.partner_latitude = 45.0
    @user.partner_longitude = 5.0
    assert_equal [45.0, 5.0], @user.partner_location
  end

  test 'activity! updates last_activity_at' do
    last_activity = @user.last_activity_at
    @user.activity!
    assert_not_equal last_activity, @user.reload.last_activity_at
  end

  test 'partner_check! updates last_partner_check_at' do
    last_check = @user.last_partner_check_at
    @user.partner_check!
    assert_not_equal last_check, @user.reload.last_partner_check_at
    assert_nil @user.partner_notified_at
  end

  test 'app_path returns the correct path' do
    assert_equal "/climbers/#{@user.slug_name}", @user.app_path
  end

  test 'deletable? returns true if not deleted' do
    assert @user.deletable?
    @user.deleted_at = Time.current
    assert_not @user.deletable?
  end

  test 'delete anonymizes the user' do
    @user.delete
    @user.reload
    assert_equal 'Anonyme', @user.first_name
    assert_nil @user.last_name
    assert_match(/@delete.mail/, @user.email)
    assert_not_nil @user.deleted_at
  end

  test 'summary_to_json returns correct keys' do
    summary = @user.summary_to_json
    assert_equal @user.id, summary[:id]
    assert_equal @user.first_name, summary[:first_name]
    assert_equal @user.full_name, summary[:full_name]
    assert_equal @user.app_path, summary[:app_path]
  end
end
