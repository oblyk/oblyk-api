# frozen_string_literal: true

require 'test_helper'

class ClimbingSessionTest < ActiveSupport::TestCase
  setup do
    @user = users(:normal_user)
    @climbing_session = ClimbingSession.create!(
      user: @user,
      session_date: Date.current,
      description: 'Super séance'
    )
  end

  test 'should be valid' do
    assert @climbing_session.valid?
  end

  test 'belongs to user' do
    assert_equal @user, @climbing_session.user
  end

  test 'has many ascents' do
    assert_respond_to @climbing_session, :ascents
    assert_respond_to @climbing_session, :ascent_gym_routes
    assert_respond_to @climbing_session, :ascent_crag_routes
  end

  test 'remove_if_empty! should destroy session if no description and no ascents' do
    session = ClimbingSession.create!(user: @user, session_date: Date.yesterday)
    assert_difference 'ClimbingSession.count', -1 do
      session.remove_if_empty!
    end
  end

  test 'remove_if_empty! should NOT destroy session if it has a description' do
    @climbing_session.description = 'Une description'
    @climbing_session.save
    assert_no_difference 'ClimbingSession.count' do
      @climbing_session.remove_if_empty!
    end
  end

  test 'remove_if_empty! should NOT destroy session if it has ascents' do
    session = ClimbingSession.create!(user: @user, session_date: Date.yesterday)
    session.stub :ascents, [1] do
      assert_no_difference 'ClimbingSession.count' do
        session.remove_if_empty!
      end
    end
  end

  test 'summary_to_json returns correct structure' do
    json = @climbing_session.summary_to_json
    assert_equal @climbing_session.id, json[:id]
    assert_equal @user.id, json[:user_id]
    assert_equal @climbing_session.session_date, json[:session_date]
    assert_kind_of Array, json[:crags]
    assert_kind_of Array, json[:gyms]
    assert_kind_of Hash, json[:stats]
  end

  test 'summary_to_json for other user hides description' do
    json = @climbing_session.summary_to_json(for_current_user: false)
    assert_nil json[:description]
  end

  test 'detail_to_json returns correct structure' do
    json = @climbing_session.detail_to_json
    assert_equal @climbing_session.id, json[:id]
    assert_includes json, :previous_climbing_session
    assert_includes json, :next_climbing_session
    assert_includes json, :gym_ascents
    assert_includes json, :crag_ascents
    assert_includes json, :users
    assert_equal 'Super séance', json[:description]
  end

  test 'previous and next climbing sessions' do
    ClimbingSession.create!(user: @user, session_date: Date.current - 2.days)
    ClimbingSession.create!(user: @user, session_date: Date.current + 2.days)

    json = @climbing_session.detail_to_json
    assert_equal (Date.current - 2.days).to_s, json[:previous_climbing_session].to_s
    assert_equal (Date.current + 2.days).to_s, json[:next_climbing_session].to_s
  end
end
