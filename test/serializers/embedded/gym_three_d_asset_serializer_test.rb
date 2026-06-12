# frozen_string_literal: true

require 'test_helper'

class EmbeddedGymThreeDAssetSerializerTest < ActiveSupport::TestCase
  setup do
    @gym_three_d_asset = gym_three_d_assets(:asset_1)
    @serializer = Embedded::GymThreeDAssetSerializer.new(@gym_three_d_asset)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @gym_three_d_asset.id, attributes['id']
    assert_equal @gym_three_d_asset.name, attributes['name']
    assert_equal @gym_three_d_asset.slug_name, attributes['slug_name']
    assert_equal @gym_three_d_asset.description, attributes['description']
  end
end
