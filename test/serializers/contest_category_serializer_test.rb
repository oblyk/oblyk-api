# frozen_string_literal: true

require 'test_helper'

class ContestCategorySerializerTest < ActiveSupport::TestCase
  setup do
    @category = contest_categories(:category_u16)
    @serializer = ContestCategorySerializer.new(@category)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @category.id, attributes['id']
    assert_equal @category.name, attributes['name']

    if @category.slug_name.nil?
      assert_nil attributes['slug_name']
    else
      assert_equal @category.slug_name, attributes['slug_name']
    end

    assert_equal @category.order, attributes['order']
    assert_equal @category.registration_obligation, attributes['registration_obligation']
    assert_equal @category.contest_id, attributes['contest_id']
    assert_equal @category.created_at.as_json, attributes['history']['created_at']
  end

  test 'It includes contest if specified' do
    serializer = ContestCategorySerializer.new(@category, { include: [:contest] })
    serialization = JSON.parse(serializer.serializable_hash.to_json)
    assert_not_nil serialization['included']
    assert serialization['included'].any? { |inc| inc['type'] == 'contest' }
  end
end
