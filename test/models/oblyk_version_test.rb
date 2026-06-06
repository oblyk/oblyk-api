# frozen_string_literal: true

require 'test_helper'

class OblykVersionTest < ActiveSupport::TestCase
  setup do
    @user = users(:normal_user)
    @created_at = Time.current
    @changeset = { 'name' => ['Old Name', 'New Name'] }

    @version = Minitest::Mock.new
    @version.expect :event, 'update'
    @version.expect :created_at, @created_at
    @version.expect :changeset, @changeset
    @version.expect :whodunnit, @user.id
  end

  test 'version_detail returns formatted version with user details' do
    detail = OblykVersion.version_detail(@version)

    assert_equal 'update', detail[:event]
    assert_equal @created_at, detail[:created_at]
    assert_equal @changeset, detail[:changes]
    assert_not_nil detail[:user]
    assert_equal @user.uuid, detail[:user][:uuid]
    assert_equal @user.full_name, detail[:user][:name]
    assert_equal @user.slug_name, detail[:user][:slug_name]
  end

  test 'version_detail returns formatted version without user if whodunnit is nil' do
    version_without_user = Minitest::Mock.new
    version_without_user.expect :event, 'create'
    version_without_user.expect :created_at, @created_at
    version_without_user.expect :changeset, { 'id' => [nil, 1] }
    version_without_user.expect :whodunnit, nil

    detail = OblykVersion.version_detail(version_without_user)

    assert_equal 'create', detail[:event]
    assert_nil detail[:user]
  end

  test 'index returns formatted list of versions' do
    # We need a second mock for the index test
    version2 = Minitest::Mock.new
    version2.expect :event, 'create'
    version2.expect :created_at, @created_at
    version2.expect :changeset, {}
    version2.expect :whodunnit, nil

    versions = [@version, version2]

    result = OblykVersion.index(versions)

    assert_equal 2, result[:versions_count]
    assert_equal 2, result[:versions].length
    assert_equal 'update', result[:versions][0][:event]
    assert_equal 'create', result[:versions][1][:event]
  end
end
