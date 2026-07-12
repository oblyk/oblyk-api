# frozen_string_literal: true

require 'test_helper'

class AuthorTest < ActiveSupport::TestCase
  setup do
    @author = authors(:lucien)
  end

  test 'author is valid' do
    assert @author.valid?
  end

  test 'author is invalid without name' do
    @author.name = nil
    assert_not @author.valid?
    assert_includes @author.errors.attribute_names, :name
  end

  test 'author is invalid without description' do
    @author.description = nil
    assert_not @author.valid?
    assert_includes @author.errors.attribute_names, :description
  end

  test 'author belongs to user' do
    assert_not_nil @author.user
    assert_kind_of User, @author.user
  end

  test 'summary_to_json returns expected keys' do
    json = @author.summary_to_json
    assert_equal @author.id, json[:id]
    assert_equal @author.name, json[:name]
    assert_equal @author.description, json[:description]
    assert_equal @author.user_id, json[:user_id]
    assert_includes json.keys, :attachments
  end

  test 'detail_to_json returns expected keys' do
    json = @author.detail_to_json
    assert_equal @author.id, json[:id]
    assert_equal @author.name, json[:name]
    assert_equal @author.description, json[:description]
    assert_equal @author.user_id, json[:user_id]
    assert_includes json.keys, :attachments
    assert_includes json[:attachments].keys, :cover
  end

  test 'description is stripped of tags before validation' do
    @author.description = '<b>Grimpant</b>'
    @author.save
    assert_equal 'Grimpant', @author.description
  end
end
