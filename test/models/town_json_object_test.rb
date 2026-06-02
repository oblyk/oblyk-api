# frozen_string_literal: true

require 'test_helper'

class TownJsonObjectTest < ActiveSupport::TestCase
  setup do
    @town_json_object = town_json_objects(:valence_json)
  end

  test 'town_json_object is valid' do
    assert @town_json_object.valid?
  end

  test 'town_json_object belongs to town' do
    assert_equal towns(:valence), @town_json_object.town
  end
end
