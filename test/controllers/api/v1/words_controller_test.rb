# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class WordsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @word = words(:with_fingers)
        @api_headers = api_headers
        @api_access_token_headers = api_access_token_headers
      end

      test 'should get index' do
        get api_v1_words_url, headers: @api_headers, as: :json
        assert_response :success
      end

      test 'should search words' do
        @word.refresh_search_index
        get search_api_v1_words_url(query: 'doigts'), headers: @api_headers, as: :json
        assert_response :success
        json_response = JSON.parse(response.body)
        assert(json_response.any? { |w| w['name'] == @word.name })
      end

      test 'should show word' do
        get api_v1_word_url(@word), headers: @api_headers, as: :json
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @word.name, json_response['name']
      end

      test 'should get word versions' do
        get versions_api_v1_word_url(@word), headers: @api_headers, as: :json
        assert_response :success
      end

      test 'should create word when logged in' do
        assert_difference('Word.count') do
          post api_v1_words_url,
               params: { word: { name: 'Nouvel mot', definition: 'Une nouvelle définition' } },
               headers: @api_headers,
               as: :json
        end
        assert_response :success
      end

      test 'should return an error when I create it with invalid parameters' do
        post api_v1_words_url,
             params: { word: { name: 'Nouvel mot', definition: nil } },
             headers: @api_headers,
             as: :json
        assert_response :unprocessable_entity
        assert_not_empty JSON.parse(response.body)['error']
      end

      test 'should not create word when not logged in' do
        assert_no_difference('Word.count') do
          post api_v1_words_url,
               params: { word: { name: 'Nouvel mot', definition: 'Une nouvelle définition' } },
               headers: @api_access_token_headers,
               as: :json
        end
        assert_response :unauthorized
      end

      test 'should update word when logged in' do
        patch api_v1_word_url(@word),
              params: { word: { name: 'Nom modifié' } },
              headers: @api_headers,
              as: :json
        assert_response :success
        @word.reload
        assert_equal 'Nom modifié', @word.name
      end

      test 'should not update word when invalid parameters' do
        patch api_v1_word_url(@word),
              params: { word: { name: nil } },
              headers: @api_headers,
              as: :json
        assert_response :unprocessable_entity
        assert_not_empty JSON.parse(response.body)['error']
      end

      test 'should not update word when not logged in' do
        patch api_v1_word_url(@word),
              params: { word: { name: 'Nom modifié' } },
              headers: @api_access_token_headers,
              as: :json
        assert_response :unauthorized
      end

      test 'should destroy word when super_admin' do
        assert_difference('Word.count', -1) do
          delete api_v1_word_url(@word),
                 headers: api_headers(user: :super_admin_user),
                 as: :json
        end
        assert_response :no_content
      end

      test 'should not destroy word when not super_admin' do
        assert_no_difference('Word.count') do
          delete api_v1_word_url(@word),
                 headers: @api_headers,
                 as: :json
        end
        assert_response :forbidden
      end
    end
  end
end
