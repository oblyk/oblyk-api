# frozen_string_literal: true

require 'test_helper'

class GuideBookWebSerializerTest < ActiveSupport::TestCase
  setup do
    @guide_book_web = guide_book_webs(:guide_book_web_1)
    @serializer = GuideBookWebSerializer.new(@guide_book_web)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @guide_book_web.id, attributes['id']
    assert_equal @guide_book_web.name, attributes['name']
    assert_equal @guide_book_web.url, attributes['url']
    assert_equal @guide_book_web.publication_year, attributes['publication_year']
    assert_equal @guide_book_web.created_at.as_json, attributes['history']['created_at']
    assert_equal @guide_book_web.updated_at.as_json, attributes['history']['updated_at']
  end

  test 'It contains relationships' do
    relationships = @serialization['data']['relationships']
    assert_not_nil relationships['user']
    assert_not_nil relationships['crag']
    assert_equal @guide_book_web.user_id, relationships['user']['data']['id'].to_i
    assert_equal @guide_book_web.crag_id, relationships['crag']['data']['id'].to_i
  end
end
