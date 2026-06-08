# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class OrganizationsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = users(:normal_user)
        @other_user = users(:other_user)
        @organization = organizations(:oblyk_orga)
        @other_organization = organizations(:public_orga) # other_user n'est pas membre de celle-ci par défaut dans les fixtures si on suit organization_users.yml
        @headers = api_headers(user: :normal_user)
        @other_headers = api_headers(user: :other_user)
      end

      test 'should get index of my organizations' do
        get api_v1_organizations_url, headers: @headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
        assert_equal 1, json_response.size
        assert_equal @organization.id, json_response.first['id']
      end

      test 'should show my organization' do
        get api_v1_organization_url(@organization), headers: @headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @organization.id, json_response['id']
      end

      test 'should not show an organization I do not own' do
        # public_orga n'a pas de membres dans fixtures, donc personne ne devrait y avoir accès sauf via protected_by_owner
        get api_v1_organization_url(@other_organization), headers: @headers
        assert_response :forbidden
      end

      test 'should create organization' do
        assert_difference('Organization.count', 1) do
          post api_v1_organizations_url,
               params: {
                 organization: {
                   name: 'New Organization',
                   email: 'new@orga.com',
                   api_usage_type: 'personal'
                 }
               },
               headers: @headers, as: :json
        end
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 'New Organization', json_response['name']
        
        # Vérifie que le créateur est membre
        new_orga = Organization.find(json_response['id'])
        assert_includes new_orga.users, @user
      end

      test 'should update my organization' do
        patch api_v1_organization_url(@organization),
              params: {
                organization: {
                  name: 'Updated Name'
                }
              },
              headers: @headers, as: :json
        assert_response :success
        @organization.reload
        assert_equal 'Updated Name', @organization.name
      end

      test 'should not update an organization I do not own' do
        patch api_v1_organization_url(@other_organization),
              params: {
                organization: {
                  name: 'Unauthorized Update'
                }
              },
              headers: @headers, as: :json
        assert_response :forbidden
      end

      test 'should destroy my organization' do
        assert_difference('Organization.count', -1) do
          delete api_v1_organization_url(@organization), headers: @headers
        end
        assert_response :no_content
      end

      test 'should not destroy an organization I do not own' do
        assert_no_difference('Organization.count') do
          delete api_v1_organization_url(@other_organization), headers: @headers
        end
        assert_response :forbidden
      end

      test 'should get api access token' do
        get api_access_token_api_v1_organization_url(@organization), headers: @headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @organization.api_access_token, json_response['api_access_token']
      end

      test 'should refresh api access token' do
        old_token = @organization.api_access_token
        put refresh_api_access_token_api_v1_organization_url(@organization), headers: @headers
        assert_response :success
        @organization.reload
        assert_not_equal old_token, @organization.api_access_token
        json_response = JSON.parse(response.body)
        assert_equal @organization.api_access_token, json_response['api_access_token']
      end

      test 'should not access any action if not logged in' do
        # On utilise des headers avec un token d'organisation mais sans Authorization (session)
        # On s'attend à du 401 si protected_by_session échoue
        get api_v1_organizations_url, headers: api_access_token_headers
        assert_response :unauthorized
      end
    end
  end
end
