# frozen_string_literal: true

require 'test_helper'

class Api::V1::ChampionshipContestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @gym = gyms(:my_gym)
    @championship = championships(:championship_2) # Use one without contest_1 yet
    @contest = contests(:contest_1)
    @auth_headers = api_headers(user: :super_admin_user)
  end

  test 'should add contest to championship' do
    assert_difference('ChampionshipContest.count') do
      post api_v1_gym_championship_championship_contests_url(gym_id: @gym.id, championship_id: @championship.id),
           params: { championship: { contest_id: @contest.id } },
           headers: @auth_headers, as: :json
    end
    assert_response :no_content
  end

  test 'should remove contest from championship' do
    # First add it
    ChampionshipContest.create(championship: @championship, contest: @contest)
    
    assert_difference('ChampionshipContest.count', -1) do
      delete delete_api_v1_gym_championship_championship_contests_url(gym_id: @gym.id, championship_id: @championship.id),
             params: { championship: { contest_id: @contest.id } },
             headers: @auth_headers, as: :json
    end
    assert_response :no_content
  end
end
