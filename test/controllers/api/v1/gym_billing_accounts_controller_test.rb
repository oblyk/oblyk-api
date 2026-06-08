# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class GymBillingAccountsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @billing_account = gym_billing_accounts(:account_1)
        
        @super_admin_headers = api_headers(user: :super_admin_user)
        @subscription_admin_headers = api_headers(user: :lulu) # lulu a le rôle manage_subscription
        @normal_admin_headers = api_headers(user: :gym_route_setter_user) # gym_route_setter_user est admin mais sans manage_subscription
      end

      test 'should show gym billing account' do
        get api_v1_gym_gym_billing_account_url(gym_id: @gym.id, id: @billing_account.id),
            headers: @subscription_admin_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @billing_account.email, json_response['email']
      end

      test 'should create gym billing account' do
        # On crée une nouvelle salle sans compte de facturation pour le test
        new_gym = Gym.create!(
          name: 'New Gym',
          address: 'Address',
          postal_code: '12345',
          code_country: 'fr',
          country: 'France',
          city: 'City',
          big_city: 'Big City',
          latitude: 0,
          longitude: 0
        )
        # On ajoute lulu comme admin de cette nouvelle salle
        GymAdministrator.create!(
          user: users(:lulu),
          gym: new_gym,
          roles: [GymRole::MANAGE_SUBSCRIPTION],
          requested_email: 'lulu@oblyk.org'
        )

        assert_difference('GymBillingAccount.count', 1) do
          post api_v1_gym_gym_billing_accounts_url(gym_id: new_gym.id),
               params: {
                 gym_billing_account: {
                   email: 'new@account.com'
                 }
               },
               headers: @subscription_admin_headers, as: :json
        end
        assert_response :success
        new_gym.reload
        assert_not_nil new_gym.gym_billing_account_id
      end

      test 'should update gym billing account' do
        patch api_v1_gym_gym_billing_account_url(gym_id: @gym.id, id: @billing_account.id),
              params: {
                gym_billing_account: {
                  email: 'updated@account.com'
                }
              },
              headers: @subscription_admin_headers, as: :json
        assert_response :success
        @billing_account.reload
        assert_equal 'updated@account.com', @billing_account.email
      end

      test 'should not show gym billing account if not authorized' do
        get api_v1_gym_gym_billing_account_url(gym_id: @gym.id, id: @billing_account.id),
            headers: @normal_admin_headers
        assert_response :forbidden
      end

      test 'should not update gym billing account if not authorized' do
        patch api_v1_gym_gym_billing_account_url(gym_id: @gym.id, id: @billing_account.id),
              params: {
                gym_billing_account: {
                  email: 'hacker@account.com'
                }
              },
              headers: @normal_admin_headers, as: :json
        assert_response :forbidden
      end

      test 'super admin should have access' do
        get api_v1_gym_gym_billing_account_url(gym_id: @gym.id, id: @billing_account.id),
            headers: @super_admin_headers
        assert_response :success
      end
      test 'should not create gym billing account with invalid params' do
        post api_v1_gym_gym_billing_accounts_url(gym_id: @gym.id),
             params: {
               gym_billing_account: {
                 email: ''
               }
             },
             headers: @subscription_admin_headers, as: :json
        assert_response :unprocessable_entity
      end

      test 'should not update gym billing account with invalid params' do
        patch api_v1_gym_gym_billing_account_url(gym_id: @gym.id, id: @billing_account.id),
              params: {
                gym_billing_account: {
                  email: ''
                }
              },
              headers: @subscription_admin_headers, as: :json
        assert_response :unprocessable_entity
      end
    end
  end
end
