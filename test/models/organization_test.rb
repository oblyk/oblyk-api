# frozen_string_literal: true

require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @organization = organizations(:oblyk_orga)
  end

  test 'valid organization' do
    assert @organization.valid?
  end

  test 'invalid without name' do
    @organization.name = nil
    assert_not @organization.valid?
    assert @organization.errors[:name].present?
  end

  test 'invalid without email' do
    @organization.email = nil
    assert_not @organization.valid?
    assert @organization.errors[:email].present?
  end

  test 'invalid with bad email format' do
    @organization.email = 'bad-email'
    assert_not @organization.valid?
    assert @organization.errors[:email].present?
  end

  test 'invalid without api_usage_type' do
    @organization.api_usage_type = nil
    assert_not @organization.valid?
    assert @organization.errors[:api_usage_type].present?
  end

  test 'invalid with wrong api_usage_type' do
    @organization.api_usage_type = 'wrong_type'
    assert_not @organization.valid?
    assert @organization.errors[:api_usage_type].present?
  end

  test 'name must be unique' do
    duplicate_organization = Organization.new(
      name: @organization.name,
      email: 'other@mail.com',
      api_usage_type: 'personal'
    )
    assert_not duplicate_organization.valid?
    assert duplicate_organization.errors[:name].present?
  end

  test 'has many users' do
    assert @organization.users.count >= 1
    assert @organization.users.first.is_a?(User)
  end

  test 'refresh_api_access_token! updates the token' do
    old_token = @organization.api_access_token
    @organization.refresh_api_access_token!
    assert_not_equal old_token, @organization.api_access_token
  end

  test 'summary_to_json returns expected keys' do
    summary = @organization.summary_to_json
    assert_equal @organization.id, summary[:id]
    assert_equal @organization.name, summary[:name]
    assert_includes summary.keys, :slug_name
    assert_includes summary.keys, :api_usage_type
  end

  test 'detail_to_json returns expected keys' do
    detail = @organization.detail_to_json
    assert_equal @organization.id, detail[:id]
    assert_includes detail.keys, :organization_users
    assert_includes detail.keys, :history
    assert detail[:organization_users].is_a?(Array)
  end

  test 'sends email notification after create' do
    assert_enqueued_emails 1 do
      Organization.create!(
        name: 'New Orga',
        email: 'new@orga.com',
        api_usage_type: 'personal'
      )
    end
  end
end
