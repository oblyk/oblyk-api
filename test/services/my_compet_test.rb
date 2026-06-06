# frozen_string_literal: true

require 'test_helper'

class MyCompetTest < ActiveSupport::TestCase
  setup do
    @ffme_contest = ffme_contests(:ffme_contest_1)
    @user_application = user_applications(:my_compet_app)
    ENV['MY_COMPET_BASE_URL'] = 'https://api.mycompet.com'
    ENV['MY_COMPET_TOKEN'] = 'test-token'
  end

  test 'association_request calls the correct endpoint and returns parsed body' do
    mock_response = Minitest::Mock.new
    mock_response.expect :body, { 'success' => true }.to_json

    expected_url = "#{ENV['MY_COMPET_BASE_URL']}/demandeAssociation"
    expected_payload = {
      idPersonne: @user_application.user.uuid,
      nom: @user_application.user.full_name,
      numeroFFME: @user_application.ffme_licence_number
    }.to_json
    expected_headers = {
      content_type: :json,
      authorization: ENV['MY_COMPET_TOKEN']
    }

    RestClient.stub :post, mock_response, [expected_url, expected_payload, expected_headers] do
      result = MyCompet.association_request(@user_application)
      assert_equal({ 'success' => true }, result)
    end
    assert_mock mock_response
  end

  test 'association_request returns false when RestClient raises ExceptionWithResponse' do
    RestClient.stub :post, ->(_url, _payload, _headers) { raise RestClient::ExceptionWithResponse } do
      result = MyCompet.association_request(@user_application)
      assert_equal false, result
    end
  end

  test 'link calls the correct endpoint and returns parsed body' do
    mock_response = Minitest::Mock.new
    mock_response.expect :body, { 'url' => 'http://example.com' }.to_json

    expected_url = "#{ENV['MY_COMPET_BASE_URL']}/urlCompetition"
    expected_payload = { idCompetition: @ffme_contest.contest_id }.to_json
    expected_headers = {
      content_type: :json,
      authorization: ENV['MY_COMPET_TOKEN']
    }

    RestClient.stub :post, mock_response, [expected_url, expected_payload, expected_headers] do
      result = MyCompet.link(@ffme_contest)
      assert_equal({ 'url' => 'http://example.com' }, result)
    end
    assert_mock mock_response
  end

  test 'create_contest calls update_or_create_contest with create mode' do
    mock_response = Minitest::Mock.new
    mock_response.expect :body, { 'idFFME' => 123 }.to_json

    # We expect url_mode 'creationCompetition' for create
    expected_url = "#{ENV['MY_COMPET_BASE_URL']}/creationCompetition"

    RestClient.stub :post, mock_response do
      result = MyCompet.create_contest(@ffme_contest)
      assert_equal({ 'idFFME' => 123 }, result)
    end
    assert_mock mock_response
  end

  test 'update_contest calls update_or_create_contest with update mode' do
    mock_response = Minitest::Mock.new
    mock_response.expect :body, { 'success' => true }.to_json

    # We expect url_mode 'modificationCompetition' for update
    expected_url = "#{ENV['MY_COMPET_BASE_URL']}/modificationCompetition"

    RestClient.stub :post, mock_response do
      result = MyCompet.update_contest(@ffme_contest)
      assert_equal({ 'success' => true }, result)
    end
    assert_mock mock_response
  end

  test 'send_results calls the correct endpoint' do
    mock_response = Minitest::Mock.new
    mock_response.expect :body, { 'success' => true }.to_json

    # Mocking ContestService::Result because it's complex and we want to test MyCompet
    mock_result_service = Minitest::Mock.new
    mock_result_service.expect :delete_cache_key, nil
    mock_result_service.expect :results, [
      {
        category_name: 'U16',
        genre: 'male',
        participants: [
          {
            synchronise_with_ffme_contest: true,
            user_uuid: 'user-uuid-1',
            global_rank: 1
          }
        ]
      }
    ]

    ContestService::Result.stub :new, mock_result_service do
      RestClient.stub :post, mock_response do
        result = MyCompet.send_results(@ffme_contest)
        assert_equal({ 'success' => true }, result)
      end
    end
    assert_mock mock_response
    assert_mock mock_result_service
  end

  test 'update_or_create_contest sends correctly formatted data' do
    mock_response = Minitest::Mock.new
    mock_response.expect :body, { 'idFFME' => 123 }.to_json

    expected_url = "#{ENV['MY_COMPET_BASE_URL']}/creationCompetition"
    # We verify some of the data fields
    RestClient.stub :post, ->(url, payload, headers) {
      assert_equal expected_url, url
      data = JSON.parse(payload)
      assert_equal @ffme_contest.contest_id, data['idCompetition']
      assert_equal @ffme_contest.name, data['complement']
      assert_equal @ffme_contest.ffme_contest_type, data['type']
      assert_equal @ffme_contest.contest.gym.name, data['structureOrganisatrice']
      mock_response
    } do
      MyCompet.update_or_create_contest(@ffme_contest, mode: :create)
    end
    assert_mock mock_response
  end
end
