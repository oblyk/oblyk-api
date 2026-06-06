# frozen_string_literal: true

require 'test_helper'

class GymRouteTest < ActiveSupport::TestCase
  setup do
    @gym_route = gym_routes(:gym_route_one)
  end

  test 'gym_route is valid' do
    assert @gym_route.valid?
  end

  test 'gym_route is invalid without opened_at' do
    @gym_route.opened_at = nil
    assert_not @gym_route.valid?
  end

  test 'gym_route is invalid with wrong climbing_type' do
    @gym_route.climbing_type = 'wrong_type'
    assert_not @gym_route.valid?
  end

  test 'calculated_point returns points if set' do
    @gym_route.points = 500
    assert_equal 500, @gym_route.calculated_point
  end

  test 'grade_to_s returns grade text' do
    assert_equal '6a', @gym_route.grade_to_s
  end

  test 'mounted? returns true if dismounted_at is nil' do
    @gym_route.dismounted_at = nil
    assert @gym_route.mounted?
    assert_not @gym_route.dismounted?
  end

  test 'dismount! sets dismounted_at' do
    assert_nil @gym_route.dismounted_at
    @gym_route.dismount!
    assert_not_nil @gym_route.dismounted_at
    assert @gym_route.dismounted?
  end

  test 'mount! unsets dismounted_at' do
    @gym_route.dismounted_at = Time.current
    assert @gym_route.dismounted?
    @gym_route.mount!
    assert_nil @gym_route.dismounted_at
    assert @gym_route.mounted?
  end

  test 'summary_to_json returns a hash' do
    summary = @gym_route.summary_to_json
    assert_kind_of Hash, summary
    assert_equal @gym_route.id, summary[:id]
  end

  test 'detail_to_json returns a hash' do
    detail = @gym_route.detail_to_json
    assert_kind_of Hash, detail
    assert_equal @gym_route.id, detail[:id]
  end

  test 'tags returns an array of tags' do
    @gym_route.sections = [{ 'grade' => '6a', 'tags' => %w[tag1 tag2] }]
    assert_equal %w[tag1 tag2], @gym_route.tags
  end

  test 'styles returns an array of styles' do
    @gym_route.sections = [{ 'grade' => '6a', 'styles' => ['style1'] }]
    assert_equal ['style1'], @gym_route.styles
  end
  test 'update_form_ascents! updates ascents_count' do
    AscentGymRoute.create!(
      user: users(:normal_user),
      gym: gyms(:my_gym),
      gym_route: @gym_route,
      ascent_status: 'sent',
      climbing_type: 'bouldering',
      sections: [{ 'grade' => '6a', 'grade_value' => 32 }],
      released_at: Date.current
    )

    @gym_route.update_form_ascents!
    @gym_route.reload
    assert_equal 1, @gym_route.ascents_count
  end

  test 'calculated_point with point_by_grade' do
    gym = gyms(:my_gym)
    gym.update!(boulder_ranking: 'point_by_grade')
    @gym_route.update!(min_grade_value: 32) # 6a

    assert @gym_route.calculated_point.positive?
  end
end
