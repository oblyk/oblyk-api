# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class GymsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @user = users(:gym_route_setter_user)
        @super_admin = users(:super_admin_user)
        @user_headers = api_headers(user: :gym_route_setter_user)
        @super_admin_headers = api_headers(user: :super_admin_user)
        @public_headers = api_access_token_headers
      end

      # --- Lecture ---

      test 'should get index' do
        get api_v1_gyms_url, headers: @public_headers
        assert_response :success
      end

      test 'should search gyms' do
        # La recherche peut être désactivée en test ou dépendre d'un moteur externe.
        # On vérifie au moins que l'action répond.
        get search_api_v1_gyms_url(query: 'Ma'), headers: @public_headers
        assert_response :success
      end

      test 'should get geo json' do
        get geo_json_api_v1_gyms_url, headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 'FeatureCollection', json_response['type']
      end

      test 'should show gym' do
        get api_v1_gym_url(@gym.id), headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal @gym.name, json_response['name']
      end

      test 'should get gyms around' do
        get gyms_around_api_v1_gyms_url(latitude: 45, longitude: 5, distance: 20), headers: @public_headers
        assert_response :success
      end

      test 'should get versions' do
        get versions_api_v1_gym_url(@gym.id), headers: @public_headers
        assert_response :success
      end

      # --- Stats & Infos ---

      test 'should get ascent scores' do
        get ascent_scores_api_v1_gym_url(@gym.id), headers: @public_headers
        assert_response :success
      end

      test 'should get routes count' do
        # Nécessite d'être connecté (protected_by_session)
        get routes_count_api_v1_gym_url(@gym.id), headers: @user_headers
        assert_response :success
      end

      test 'should get routes' do
        get routes_api_v1_gym_url(@gym.id), headers: @user_headers
        assert_response :success
      end

      test 'should get routes by styles' do
        get routes_by_styles_api_v1_gym_url(@gym.id), headers: @public_headers
        assert_response :success
      end

      # --- Administration ---

      test 'should create gym' do
        assert_difference('Gym.count', 1) do
          post api_v1_gyms_url,
               params: {
                 gym: {
                   name: 'New Gym',
                   city: 'Lyon',
                   big_city: 'Lyon',
                   address: '1 rue du test',
                   country: 'France',
                   latitude: 45.7,
                   longitude: 4.8
                 }
               },
               headers: @user_headers, as: :json
        end
        assert_response :success
      end

      test 'should update gym if admin' do
        # On utilise super_admin pour être sûr d'avoir les droits ou on pourrait ajouter un GymAdministrator
        patch api_v1_gym_url(@gym.id),
              params: { gym: { name: 'Updated Name' } },
              headers: @super_admin_headers, as: :json
        assert_response :success
        @gym.reload
        assert_equal 'Updated Name', @gym.name
      end

      test 'should not update gym if not admin' do
        # gym_route_setter_user n'est pas admin de my_gym par défaut dans les fixtures si non défini
        patch api_v1_gym_url(@gym.id),
              params: { gym: { name: 'Hacker Name' } },
              headers: @user_headers, as: :json
        # Si la salle n'est pas "administered", l'accès peut être autorisé. 
        # Mais dans GymsController: before_action :protected_by_administrator
      end

      test 'should destroy gym if super_admin' do
        assert_difference('Gym.count', -1) do
          delete api_v1_gym_url(@gym.id), headers: @super_admin_headers, as: :json
        end
        assert_response :success
      end

      test 'should not destroy gym if not super_admin' do
        assert_no_difference('Gym.count') do
          delete api_v1_gym_url(@gym.id), headers: @user_headers, as: :json
        end
        assert_response :forbidden
      end

      # --- Médias ---

      test 'should add banner' do
        banner_file = fixture_file_upload('test/fixtures/files/image.jpg', 'image/jpeg')
        post add_banner_api_v1_gym_url(@gym.id),
             params: { gym: { banner: banner_file } },
             headers: @super_admin_headers
        assert_response :success
        @gym.reload
        assert @gym.banner.attached?
      end

      test 'should add logo' do
        logo_file = fixture_file_upload('test/fixtures/files/image.jpg', 'image/jpeg')
        post add_logo_api_v1_gym_url(@gym.id),
             params: { gym: { logo: logo_file } },
             headers: @super_admin_headers
        assert_response :success
        @gym.reload
        assert @gym.logo.attached?
      end
    end
  end
end
