# frozen_string_literal: true

require 'test_helper'

class CragSerializerTest < ActiveSupport::TestCase
  setup do
    @crag = crags(:rocher_des_aures)
    @serializer = CragSerializer.new(@crag)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @crag.id, attributes['id']
    assert_equal @crag.name, attributes['name']
    assert_equal @crag.app_path, attributes['app_path']
    if @crag.slug_name
      assert_equal @crag.slug_name, attributes['slug_name']
    else
      assert_nil attributes['slug_name']
    end
    assert_equal @crag.latitude.to_s, attributes['latitude'].to_s
    assert_equal @crag.longitude.to_s, attributes['longitude'].to_s
    assert_equal @crag.city, attributes['city']
    assert_equal @crag.region, attributes['region']
    assert_equal @crag.elevation.to_s, attributes['elevation'].to_s
  end

  test 'It contains the approaches attribute' do
    attributes = @serialization['data']['attributes']
    assert attributes.key?('approaches')
    if @crag.min_approach_time
      assert_equal @crag.min_approach_time, attributes['approaches']['min_time']
    else
      assert_nil attributes['approaches']['min_time']
    end

    if @crag.max_approach_time
      assert_equal @crag.max_approach_time, attributes['approaches']['max_time']
    else
      assert_nil attributes['approaches']['max_time']
    end
  end

  test 'It contains the routes_figures attribute' do
    attributes = @serialization['data']['attributes']
    assert attributes.key?('routes_figures')
    if @crag.crag_routes_count
      assert_equal @crag.crag_routes_count, attributes['routes_figures']['route_count']
    end
    if @crag.min_grade_value
      assert_equal @crag.min_grade_value, attributes['routes_figures']['grade']['min_value']
    else
      assert_nil attributes['routes_figures']['grade']['min_value']
    end

    if @crag.max_grade_value
      assert_equal @crag.max_grade_value, attributes['routes_figures']['grade']['max_value']
    else
      assert_nil attributes['routes_figures']['grade']['max_value']
    end

    if @crag.min_grade_text
      assert_equal @crag.min_grade_text, attributes['routes_figures']['grade']['min_text']
    else
      assert_nil attributes['routes_figures']['grade']['min_text']
    end

    if @crag.max_grade_text
      assert_equal @crag.max_grade_text, attributes['routes_figures']['grade']['max_text']
    else
      assert_nil attributes['routes_figures']['grade']['max_text']
    end
  end

  test 'it may include attachments if specified' do
    serializer = CragSerializer.new(@crag, { params: { include_attachments: { Crag: [:cover] } } })
    serialization = JSON.parse(serializer.serializable_hash.to_json)

    assert serialization['data']['attributes'].key?('attachments')
  end

  test 'Attachment methods return correct structure' do
    assert_kind_of Hash, CragSerializer.cover_attachment(@crag)
    assert_kind_of Hash, CragSerializer.avatar_attachment(@crag)
    assert_kind_of Hash, CragSerializer.static_map_attachment(@crag)
    assert_kind_of Hash, CragSerializer.static_map_banner_attachment(@crag)

    cover = CragSerializer.cover_attachment(@crag)
    assert cover.key?(:attached)
    assert cover.key?(:attachment_type)
    assert cover.key?(:variant_path)
  end
end
