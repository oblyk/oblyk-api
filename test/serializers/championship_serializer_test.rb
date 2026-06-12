# frozen_string_literal: true

require 'test_helper'

class ChampionshipSerializerTest < ActiveSupport::TestCase
  setup do
    @championship = championships(:championship_1)
    @serializer = ChampionshipSerializer.new(@championship)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @championship.id, attributes['id']
    assert_equal @championship.name, attributes['name']
    if @championship.slug_name.nil?
      assert_nil attributes['slug_name']
    else
      assert_equal @championship.slug_name, attributes['slug_name']
    end
    if @championship.description.nil?
      assert_nil attributes['description']
    else
      assert_equal @championship.description, attributes['description']
    end
    assert_equal @championship.gym_id, attributes['gym_id']
    assert_equal @championship.combined_ranking_type, attributes['combined_ranking_type']
    if @championship.archived_at.nil?
      assert_nil attributes['archived_at']
    else
      assert_equal @championship.archived_at, attributes['archived_at']
    end
  end

  test 'It contains the contests_count attribute' do
    attributes = @serialization['data']['attributes']
    assert_equal @championship.contests.size, attributes['contests_count']
  end

  test 'It contains the history attribute' do
    history = @serialization['data']['attributes']['history']
    assert_equal @championship.created_at.as_json, history['created_at']
    assert_equal @championship.updated_at.as_json, history['updated_at']
  end

  test 'It may include contests if specified' do
    serializer = ChampionshipSerializer.new(@championship, { include: [:contests] })
    serialization = JSON.parse(serializer.serializable_hash.to_json)
    assert_not_nil serialization['included']
    assert serialization['included'].any? { |inc| inc['type'] == 'contest' }
  end

  test 'banner_attachment returns correct structure' do
    banner = ChampionshipSerializer.banner_attachment(@championship)
    assert_kind_of Hash, banner
    assert banner.key?(:attached)
  end

  test 'avatar_attachment returns same as banner_attachment' do
    avatar = ChampionshipSerializer.avatar_attachment(@championship)
    banner = ChampionshipSerializer.banner_attachment(@championship)
    assert_equal banner, avatar
  end

  test 'It includes attachments if specified in params' do
    params = {
      include_attachments: {
        Championship: [:banner]
      }
    }
    serializer = ChampionshipSerializer.new(@championship, { params: params })
    serialization = JSON.parse(serializer.serializable_hash.to_json)

    assert_not_nil serialization['data']['attributes']['attachments']
    assert_not_nil serialization['data']['attributes']['attachments']['banner']
  end
end
