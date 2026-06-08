# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class PublicationsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = users(:normal_user)
        @publication = publications(:publication_user)
        @user_headers = api_headers(user: :normal_user)
      end

      test 'should get index' do
        get api_v1_publications_url,
            params: { publishable_type: 'User', publishable_id: @user.id },
            headers: @user_headers
        assert_response :success
      end

      test 'should get drafts' do
        get drafts_api_v1_publications_url,
            params: { publishable_type: 'User', publishable_id: @user.id },
            headers: @user_headers
        assert_response :success
      end

      test 'should get my publication feed' do
        get my_publication_feed_api_v1_publications_url,
            headers: @user_headers
        assert_response :success
      end

      test 'should show publication' do
        get api_v1_publication_url(@publication),
            headers: @user_headers
        assert_response :success
      end

      test 'should create publication' do
        assert_difference('Publication.count', 1) do
          post api_v1_publications_url,
               params: {
                 publication: {
                   publishable_type: 'User',
                   publishable_id: @user.id,
                   body: 'Nouvelle publication de test'
                 }
               },
               headers: @user_headers, as: :json
        end
        assert_response :success
      end

      test 'should update publication' do
        put api_v1_publication_url(@publication),
            params: {
              publication: {
                body: 'Publication mise à jour'
              }
            },
            headers: @user_headers, as: :json
        assert_response :success
        @publication.reload
        assert_equal 'Publication mise à jour', @publication.body
      end

      test 'should publish publication' do
        lulu = users(:lulu)
        lulu_headers = api_headers(user: :lulu)

        lulu.update_column(:public_profile, true)

        draft = Publication.create!(
          publishable: lulu,
          author: lulu,
          body: 'Draft body',
          published_at: nil
        )

        put publish_api_v1_publication_url(draft),
            headers: lulu_headers
        assert_response :success
        draft.reload
        assert_not_nil draft.published_at
      end

      test 'should destroy publication' do
        publication_without_attachments = Publication.create!(
          publishable: @user,
          author: @user,
          body: 'Temp publication',
          published_at: Time.current
        )

        assert_difference('Publication.count', -1) do
          delete api_v1_publication_url(publication_without_attachments),
                 headers: @user_headers, as: :json
        end
        assert_response :success
      end
    end
  end
end
