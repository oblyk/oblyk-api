# frozen_string_literal: true

require 'test_helper'

class AscentCragRouteTest < ActiveSupport::TestCase
  setup do
    @ascent = ascent_crag_routes(:crag_ascent_one)
    @ascent.selected_sections = [0]
  end

  test 'ascent_crag_route is valid' do
    assert @ascent.valid?
  end

  test 'ascent_crag_route is invalid with wrong roping_status' do
    @ascent.roping_status = 'wrong_status'
    assert_not @ascent.valid?
  end

  test 'ascent_crag_route climbing_type is historized' do
    @ascent.climbing_type = 'bouldering'
    @ascent.valid?
    assert_equal 'sport_climbing', @ascent.climbing_type
  end

  test 'historize_ascents is called before validation' do
    new_ascent = AscentCragRoute.new(
      user: users(:normal_user),
      crag_route: crag_routes(:route_one),
      released_at: Date.current,
      ascent_status: 'sent',
      roping_status: 'lead_climb',
      selected_sections: [0]
    )
    assert new_ascent.valid?
    assert_equal 20, new_ascent.height
    assert_equal 'sport_climbing', new_ascent.climbing_type
    assert_equal 1, new_ascent.sections.count
    assert_equal '6a', new_ascent.max_grade_text
  end
end
