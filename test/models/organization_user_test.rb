# frozen_string_literal: true

require 'test_helper'

class OrganizationUserTest < ActiveSupport::TestCase
  setup do
    @organization_user = organization_users(:one)
  end

  test 'valid organization user' do
    assert @organization_user.valid?
  end

  test 'belongs to user' do
    assert @organization_user.user.is_a?(User)
  end

  test 'belongs to organization' do
    assert @organization_user.organization.is_a?(Organization)
  end
end
