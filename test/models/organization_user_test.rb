# frozen_string_literal: true

require "test_helper"

class OrganizationUserTest < ActiveSupport::TestCase
  setup do
    @organization_user = organization_users(:one)
  end

  test "valid organization user" do
    assert_predicate @organization_user, :valid?
  end

  test "belongs to user" do
    assert_kind_of User, @organization_user.user
  end

  test "belongs to organization" do
    assert_kind_of Organization, @organization_user.organization
  end
end
