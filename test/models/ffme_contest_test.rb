# frozen_string_literal: true

require 'test_helper'

class FfmeContestTest < ActiveSupport::TestCase
  setup do
    @ffme_contest = ffme_contests(:ffme_contest_1)
  end

  test 'validates presence of name and contact_email' do
    @ffme_contest.name = nil
    @ffme_contest.contact_email = nil
    assert_not @ffme_contest.valid?
    assert_includes @ffme_contest.errors.attribute_names, :name
    assert_includes @ffme_contest.errors.attribute_names, :contact_email
  end

  test 'validates status' do
    @ffme_contest.status = 'invalid_status'
    assert_not @ffme_contest.valid?
    assert_includes @ffme_contest.errors.attribute_names, :status

    @ffme_contest.status = 'create_on_my_compet'
    assert @ffme_contest.valid?
  end

  test 'validates contest_type' do
    @ffme_contest.contest_type = 'invalid_type'
    assert_not @ffme_contest.valid?
    assert_includes @ffme_contest.errors.attribute_names, :contest_type

    @ffme_contest.contest_type = 'sport_climbing'
    assert @ffme_contest.valid?
  end

  test 'summary_to_json returns correct keys' do
    json = @ffme_contest.summary_to_json
    assert_equal @ffme_contest.id, json[:id]
    assert_equal @ffme_contest.contest_id, json[:contest_id]
  end

  test 'detail_to_json returns detailed keys' do
    json = @ffme_contest.detail_to_json
    assert_equal @ffme_contest.status, json[:status]
    assert_equal @ffme_contest.contest_type, json[:contest_type]
    assert_equal @ffme_contest.name, json[:name]
    assert_equal @ffme_contest.contact_email, json[:contact_email]
    assert json.key?(:sendable)
  end

  test 'ffme_contest_type returns correct labels' do
    @ffme_contest.contest_type = 'boulder'
    assert_equal 'BLOC', @ffme_contest.ffme_contest_type

    @ffme_contest.contest_type = 'sport_climbing'
    assert_equal 'DIFFICULTE', @ffme_contest.ffme_contest_type
  end

  test 'dates calculations' do
    assert_equal @ffme_contest.start_date, @ffme_contest.min_send_date
    assert_equal @ffme_contest.end_date.next_occurring(:tuesday), @ffme_contest.max_send_date
  end

  test 'sendable? returns correct boolean' do
    @ffme_contest.start_date = Date.current - 1.day
    @ffme_contest.end_date = Date.current + 1.day
    assert @ffme_contest.sendable?

    @ffme_contest.start_date = Date.current + 1.day
    @ffme_contest.end_date = Date.current + 2.days
    assert_not @ffme_contest.sendable?
  end

  test 'create_on_my_compet! calls MyCompet and updates status' do
    mock = Minitest::Mock.new
    mock.expect :call, { 'idFFME' => 123 }, [@ffme_contest]

    MyCompet.stub :create_contest, mock do
      @ffme_contest.create_on_my_compet!
    end

    assert_mock mock
    assert_equal 123, @ffme_contest.external_ffme_contest_id
    assert_equal 'create_on_my_compet', @ffme_contest.status
  end

  test 'update_on_my_compet! calls MyCompet' do
    mock = Minitest::Mock.new
    mock.expect :call, true, [@ffme_contest]

    MyCompet.stub :update_contest, mock do
      @ffme_contest.update_on_my_compet!
    end

    assert_mock mock
  end

  test 'link_on_my_compet calls MyCompet' do
    mock = Minitest::Mock.new
    mock.expect :call, { 'url' => 'http://example.com' }, [@ffme_contest]

    MyCompet.stub :link, mock do
      result = @ffme_contest.link_on_my_compet
      assert_equal 'http://example.com', result['url']
    end

    assert_mock mock
  end

  test 'send_results! calls MyCompet and updates status' do
    mock = Minitest::Mock.new
    mock.expect :call, true, [@ffme_contest]

    MyCompet.stub :send_results, mock do
      @ffme_contest.send_results!
    end

    assert_mock mock
    assert_not_nil @ffme_contest.results_send_at
    assert_equal 'result_sent', @ffme_contest.status
  end
end
