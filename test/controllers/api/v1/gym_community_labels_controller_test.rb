# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class GymCommunityLabelsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @sector = gym_sectors(:my_gym_sector)
        @route_1 = gym_routes(:gym_route_one)
        @route_2 = gym_routes(:gym_route_two)
        
        # Create a gym administrator with manage_opening role
        @admin = users(:other_user)
        GymAdministrator.create!(
          user: @admin,
          gym: @gym,
          requested_email: @admin.email,
          roles: [GymRole::MANAGE_OPENING]
        )
        @admin_headers = api_headers(user: :other_user)
      end

      test 'should get disc chart by sector_id' do
        get disc_chart_api_v1_gym_gym_community_labels_url(gym_id: @gym.id),
            params: { sector_id: @sector.id },
            headers: @admin_headers
        assert_response :success
        assert_equal 'application/pdf', response.content_type
      end

      test 'should get disc chart by route ids' do
        get disc_chart_api_v1_gym_gym_community_labels_url(gym_id: @gym.id),
            params: { ids: [@route_1.id, @route_2.id] },
            headers: @admin_headers
        assert_response :success
        assert_equal 'application/pdf', response.content_type
      end

      test 'should be forbidden for unauthorized user' do
        user_headers = api_headers(user: :lulu)
        get disc_chart_api_v1_gym_gym_community_labels_url(gym_id: @gym.id),
            params: { sector_id: @sector.id },
            headers: user_headers
        assert_response :forbidden
      end
    end
  end
end
