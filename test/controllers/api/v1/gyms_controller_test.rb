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

      test 'should get index' do
        get api_v1_gyms_url, headers: @public_headers
        assert_response :success
      end

      test 'should get index with latitude and longitude' do
        Gym.create!(
          name: 'Autre salle',
          slug_name: 'autre-salle',
          address: '2 rue de la Paix',
          postal_code: '75000',
          code_country: 'fr',
          country: 'France',
          city: 'Paris',
          big_city: 'Paris',
          latitude: 48.8566,
          longitude: 2.3522,
          bouldering: true,
          sport_climbing: true
        )

        get api_v1_gyms_url(latitude: 45.1, longitude: 4.9), headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_instance_of Array, json_response
        assert_equal 'Ma salle', json_response.first['name']

        get api_v1_gyms_url(latitude: 48.8, longitude: 2.3), headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 'Autre salle', json_response.first['name']
      end

      test 'should search gyms' do
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

      test 'should get ascent scores' do
        get ascent_scores_api_v1_gym_url(@gym.id), headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_instance_of Array, json_response
      end

      test 'should get ascent scores with age filter' do
        user = users(:normal_user)
        ascent = ascent_gym_routes(:gym_ascent_one)
        ascent.update!(user: user, gym: @gym, released_at: Date.current, ascent_status: 'sent')
        ascent.gym_route.update!(dismounted_at: nil)

        user.update!(date_of_birth: Date.current - 25.years)
        get ascent_scores_api_v1_gym_url(@gym.id), params: { age: 'senior' }, headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert json_response.any? { |score| score['user']['id'] == user.id }, 'User (25yo) should be in senior category'

        user.update!(date_of_birth: Date.current - 9.years)
        get ascent_scores_api_v1_gym_url(@gym.id), params: { age: 'U10' }, headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert json_response.any? { |score| score['user']['id'] == user.id }, 'User (9yo) should be in U10 category'

        user.update_columns(date_of_birth: Date.current - 45.years)
        get ascent_scores_api_v1_gym_url(@gym.id), params: { age: 'A40' }, headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert json_response.any? { |score| score['user']['id'] == user.id }, 'User (45yo) should be in A40 category'

        get ascent_scores_api_v1_gym_url(@gym.id), params: { age: 'U6' }, headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert json_response.none? { |score| score['user']['id'] == user.id }, 'User (45yo) should not be in U6 category'
      end

      test 'should get routes count' do
        get routes_count_api_v1_gym_url(@gym.id), headers: @user_headers
        assert_response :success
      end

      test 'should get routes' do
        get routes_api_v1_gym_url(@gym.id), headers: @user_headers
        assert_response :success
      end

      test 'should get routes by styles' do
        route = gym_routes(:gym_route_one)
        route.update!(
          dismounted_at: nil,
          sections: [{ grade: '6a', grade_value: 32, styles: ['slab'] }]
        )

        get routes_by_styles_api_v1_gym_url(@gym.id), headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert json_response.key?('slab')
        assert_equal 1, json_response['slab']
      end

      test 'should get routes by styles with gym_space_id' do
        space = gym_spaces(:my_gym_boulder_space)
        route = gym_routes(:gym_route_one)
        route.update!(
          gym_sector: gym_sectors(:my_gym_sector),
          dismounted_at: nil,
          sections: [{ grade: '6a', grade_value: 32, styles: ['overhang'] }]
        )

        get routes_by_styles_api_v1_gym_url(@gym.id), params: { gym_space_id: space.id }, headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert json_response.key?('overhang')
        assert_equal 1, json_response['overhang']
      end

      test 'should return error on add_banner with wrong format' do
        post add_banner_api_v1_gym_url(@gym.id),
             params: {
               gym: {
                 banner: fixture_file_upload('test/fixtures/files/participants.csv', 'text/csv')
               }
             },
             headers: @super_admin_headers
        assert_response :unprocessable_content
        json_response = JSON.parse(response.body)
        assert_includes json_response['error']['base'], 'file_wrong_format'
      end

      test 'should return error on add_banner with no file' do
        post add_banner_api_v1_gym_url(@gym.id),
             params: { gym: { banner: '' } }.to_json,
             headers: @super_admin_headers.merge('Content-Type' => 'application/json')
        assert_response :unprocessable_content
        json_response = JSON.parse(response.body)
        assert_includes json_response['error']['base'], 'no_file'
      end

      test 'should return error on add_logo with wrong format' do
        post add_logo_api_v1_gym_url(@gym.id),
             params: {
               gym: {
                 logo: fixture_file_upload('test/fixtures/files/participants.csv', 'text/csv')
               }
             },
             headers: @super_admin_headers
        assert_response :unprocessable_content
        json_response = JSON.parse(response.body)
        assert_includes json_response['error']['base'], 'file_wrong_format'
      end

      test 'should return error on add_logo with no file' do
        post add_logo_api_v1_gym_url(@gym.id),
             params: { gym: { logo: '' } }.to_json,
             headers: @super_admin_headers.merge('Content-Type' => 'application/json')
        assert_response :unprocessable_content
        json_response = JSON.parse(response.body)
        assert_includes json_response['error']['base'], 'no_file'
      end

      test 'should get tree routes' do
        get tree_routes_api_v1_gym_url(@gym.id), headers: @super_admin_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_instance_of Array, json_response
        assert json_response.length.positive?

        space = json_response.first
        assert_equal 'GymSpace', space['type']
        assert space.key?('children')

        sector = space['children'].first
        assert_equal 'GymSector', sector['type']
        assert sector.key?('children')

        route = sector['children'].first
        assert_equal 'GymRoute', route['type']
        assert route.key?('route')
      end

      test 'should get tree structures' do
        get tree_structures_api_v1_gym_url(@gym.id), headers: @super_admin_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert json_response.key?('gym')
        assert_equal @gym.name, json_response['gym']['name']
        assert json_response['gym'].key?('gym_spaces')
        assert json_response['gym'].key?('gym_space_groups')
        assert json_response['gym'].key?('archived_gym_spaces')
      end

      test 'should get tree structures with archived and unarchived spaces' do
        unarchived_space = gym_spaces(:my_gym_boulder_space)
        unarchived_space.update!(archived_at: nil, gym_space_group_id: nil)

        archived_space = GymSpace.create!(
          name: 'Espace Archivé',
          gym: @gym,
          climbing_type: 'bouldering',
          archived_at: Time.current
        )

        get tree_structures_api_v1_gym_url(@gym.id), headers: @super_admin_headers
        assert_response :success
        json_response = JSON.parse(response.body)

        gym_data = json_response['gym']

        unarchived_ids = gym_data['gym_spaces'].map { |s| s['id'] }
        assert_includes unarchived_ids, unarchived_space.id
        assert_not_includes unarchived_ids, archived_space.id

        archived_ids = gym_data['archived_gym_spaces'].map { |s| s['id'] }
        assert_includes archived_ids, archived_space.id
        assert_not_includes archived_ids, unarchived_space.id
      end

      test 'should get figures' do
        figures = %w[
          contests_count
          championships_count
          gym_spaces_count
          mounted_gym_routes_count
          gym_administrators_count
          gym_openers_count
          publications_count
          publication_drafts_count
          comments_count
          videos_count
          followers_count
        ]
        get figures_api_v1_gym_url(@gym.id), params: { figures: figures }, headers: @super_admin_headers
        assert_response :success
        json_response = JSON.parse(response.body)

        figures.each do |figure|
          assert json_response.key?(figure), "Should have key #{figure}"
        end
      end

      test 'should get comments' do
        get comments_api_v1_gym_url(@gym.id), headers: @super_admin_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert json_response.key?('data')
        assert_instance_of Array, json_response['data']
      end

      test 'should get videos' do
        get videos_api_v1_gym_url(@gym.id), headers: @super_admin_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_instance_of Array, json_response
      end

      test 'should get three_d' do
        space = gym_spaces(:my_gym_boulder_space)
        space.three_d_gltf.attach(
          io: File.open('test/fixtures/files/espace_voie.gltf'),
          filename: 'espace_voie.gltf',
          content_type: 'model/gltf+json'
        )

        get three_d_api_v1_gym_url(@gym.id), headers: @public_headers
        assert_response :success
        json_response = JSON.parse(response.body)

        assert json_response.key?('spaces')
        assert json_response.key?('assets')
        assert_instance_of Array, json_response['spaces']
        assert_instance_of Array, json_response['assets']

        assert json_response['spaces'].any? { |s| s['id'] == space.id }

        assert json_response['assets'].length.positive?
      end

      test 'should get stripe customer portal' do
        stripe_session_mock = Minitest::Mock.new
        stripe_session_mock.expect :url, 'https://billing.stripe.com/p/session/test_123'
        stripe_session_mock.expect :blank?, false

        Stripe::BillingPortal::Session.stub :create, stripe_session_mock do
          get stripe_customer_portal_api_v1_gym_url(@gym.id), headers: @super_admin_headers
          assert_response :success
          json_response = JSON.parse(response.body)
          assert_equal 'https://billing.stripe.com/p/session/test_123', json_response['url']
        end
        stripe_session_mock.verify
      end

      test 'should return no content if gym has no billing account' do
        gym_without_billing = Gym.create!(
          name: 'No Billing Gym',
          slug_name: 'no-billing-gym',
          address: '3 rue de la Paix',
          postal_code: '75000',
          code_country: 'fr',
          country: 'France',
          city: 'Paris',
          big_city: 'Paris',
          latitude: 48.8566,
          longitude: 2.3522,
          bouldering: true,
          sport_climbing: true
        )
        get stripe_customer_portal_api_v1_gym_url(gym_without_billing.id), headers: @super_admin_headers
        assert_response :no_content
      end

      test 'should return no content if stripe portal is blank' do
        account = gym_billing_accounts(:account_1)
        account.update!(customer_stripe_id: nil)

        get stripe_customer_portal_api_v1_gym_url(@gym.id), headers: @super_admin_headers
        assert_response :no_content
      end


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

      test 'should return error on create gym with invalid params' do
        assert_no_difference('Gym.count') do
          post api_v1_gyms_url,
               params: {
                 gym: {
                   name: '',
                   city: 'Lyon'
                 }
               },
               headers: @user_headers, as: :json
        end
        assert_response :unprocessable_content
        json_response = JSON.parse(response.body)
        assert json_response.key?('error')
        assert json_response['error'].key?('name')
      end

      test 'should update gym if admin' do
        patch api_v1_gym_url(@gym.id),
              params: { gym: { name: 'Updated Name' } },
              headers: @super_admin_headers, as: :json
        assert_response :success
        @gym.reload
        assert_equal 'Updated Name', @gym.name
      end

      test 'should return error on update gym with invalid params' do
        patch api_v1_gym_url(@gym.id),
              params: { gym: { name: '' } },
              headers: @super_admin_headers, as: :json
        assert_response :unprocessable_content
        json_response = JSON.parse(response.body)
        assert json_response.key?('error')
        assert json_response['error'].key?('name')
      end

      test 'should not update gym if not admin' do
        patch api_v1_gym_url(@gym.id),
              params: { gym: { name: 'Hacker Name' } },
              headers: @user_headers, as: :json
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
