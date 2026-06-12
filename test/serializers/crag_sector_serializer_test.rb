# frozen_string_literal: true

require 'test_helper'

class CragSectorSerializerTest < ActiveSupport::TestCase
  setup do
    @crag_sector = crag_sectors(:sector_one)
    @serializer = CragSectorSerializer.new(@crag_sector)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @crag_sector.id, attributes['id']
    assert_equal @crag_sector.name, attributes['name']
  end
end
