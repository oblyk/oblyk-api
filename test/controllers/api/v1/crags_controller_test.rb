# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class CragsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @crag = crags(:rocher_des_aures)
        @user_headers = api_headers(user: :normal_user)
        @admin_headers = api_headers(user: :super_admin_user)

        guide_book_pdfs(:guide_book_pdf_1).pdf_file.attach(
          io: File.open(Rails.root.join('test/fixtures/files/test.pdf')),
          filename: 'test.pdf',
          content_type: 'application/pdf'
        )
        guide_book_pdfs(:guide_book_pdf_without_user).pdf_file.attach(
          io: File.open(Rails.root.join('test/fixtures/files/test.pdf')),
          filename: 'test.pdf',
          content_type: 'application/pdf'
        )
      end

      test 'should get index' do
        get api_v1_crags_url, headers: @user_headers
        assert_response :success
      end

      test 'should get index with geo location' do
        get api_v1_crags_url, params: { latitude: 44.3, longitude: 5.6 }, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        
        assert_equal 'Orpierre - Quiquillon', json_response.first['name']
        
        get api_v1_crags_url, params: { latitude: 44.4, longitude: 5.0 }, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        
        assert_equal 'Rocher des Aures', json_response.first['name']
      end

      test 'should search crags' do
        get search_api_v1_crags_url, params: { query: 'Rocher' }, headers: @user_headers
        assert_response :success
      end

      test 'should get crags with geo_search' do
        get geo_search_api_v1_crags_url, params: { latitude: 44.31, longitude: 5.49, distance: 10 }, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 1, json_response.size
        assert_equal 'Orpierre - Quiquillon', json_response.first['name']

        get geo_search_api_v1_crags_url, params: { latitude: 44.31, longitude: 5.49, distance: 100 }, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert json_response.size >= 2
        assert_equal 'Orpierre - Quiquillon', json_response.first['name']
        assert_equal 'Rocher des Aures', json_response.second['name']
      end

      test 'should return empty list if no crags near geo_search' do
        get geo_search_api_v1_crags_url, params: { latitude: 0.0, longitude: 0.0, distance: 10 }, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 0, json_response.size
      end

      test 'should get random crag' do
        get random_api_v1_crags_url, headers: @user_headers
        assert_response :success
      end

      test 'should show crag' do
        get api_v1_crag_url(@crag), headers: @user_headers
        assert_response :success
      end

      test 'should create crag' do
        assert_difference('Crag.count') do
          post api_v1_crags_url,
               params: {
                 crag: {
                   name: 'New Crag',
                   rocks: ['limestone'],
                   latitude: 45.0,
                   longitude: 5.0,
                   city: 'Test City'
                 }
               },
               headers: @user_headers,
               as: :json
        end
        assert_response :success
      end

      test 'should return unprocessable_entity on create failure' do
        assert_no_difference('Crag.count') do
          post api_v1_crags_url,
               params: {
                 crag: {
                   name: ''
                 }
               },
               headers: @user_headers,
               as: :json
        end
        assert_response :unprocessable_entity
      end

      test 'should update crag' do
        put api_v1_crag_url(@crag),
            params: { crag: { name: 'Updated Crag Name' } },
            headers: @user_headers,
            as: :json
        assert_response :success
        @crag.reload
        assert_equal 'Updated Crag Name', @crag.name
      end

      test 'should return unprocessable_entity on update failure' do
        put api_v1_crag_url(@crag),
            params: { crag: { name: '' } },
            headers: @user_headers,
            as: :json
        assert_response :unprocessable_entity
      end

      test 'should destroy crag' do
        new_crag = Crag.create!(
          name: 'To Destroy',
          rocks: ['granite'],
          latitude: 46.0,
          longitude: 6.0,
          city: 'Destroy City',
          user: users(:normal_user)
        )
        assert_difference('Crag.count', -1) do
          delete api_v1_crag_url(new_crag), headers: @admin_headers, as: :json
        end
        assert_response :success
      end

      test 'should advanced search crags' do
        post advanced_search_api_v1_crags_url, headers: @user_headers, as: :json
        assert_response :success
        json_response = JSON.parse(response.body)
        assert json_response.key?('route_figures')
        assert json_response.key?('crag_with_levels')

        post advanced_search_api_v1_crags_url,
             params: { latitude: 44.4, longitude: 5.0, distance: 20 },
             headers: @user_headers,
             as: :json
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 1, json_response['crag_with_levels'].size
        assert json_response['crag_with_levels'].key?("crag-#{@crag.id}")

        post advanced_search_api_v1_crags_url,
             params: { climbing_type: { sport_climbing: true } },
             headers: @user_headers,
             as: :json
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 2, json_response['crag_with_levels'].size

        post advanced_search_api_v1_crags_url,
             params: { season: { winter: true } },
             headers: @user_headers,
             as: :json
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 2, json_response['crag_with_levels'].size

        post advanced_search_api_v1_crags_url,
             params: { orientation: { south: true } },
             headers: @user_headers,
             as: :json
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 2, json_response['crag_with_levels'].size

        post advanced_search_api_v1_crags_url,
             params: { grade: { min: '6a', max: '6b' } },
             headers: @user_headers,
             as: :json
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 1, json_response['crag_with_levels'].size
        assert json_response['crag_with_levels'].key?("crag-#{@crag.id}")

        post advanced_search_api_v1_crags_url,
             params: { max_approach_time: 10 },
             headers: @user_headers,
             as: :json
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 1, json_response['crag_with_levels'].size
        assert json_response['crag_with_levels'].key?("crag-#{@crag.id}")
      end

      test 'should get crag versions' do
        get versions_api_v1_crag_url(@crag), headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert json_response.key?('versions')
      end

      test 'should get guide books around' do
        get guide_books_around_api_v1_crag_url(@crag), headers: @user_headers
        assert_response :success
        new_guide = GuideBookPaper.create!(name: 'Around Guide', user: users(:normal_user))
        GuideBookPaperCrag.create!(guide_book_paper: new_guide, crag: crags(:orpierre))
        
        get guide_books_around_api_v1_crag_url(@crag), headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        
        assert_equal 1, json_response.size
        assert_equal 'Around Guide', json_response.first['name']
      end

      test 'should return empty guide books around if none' do
        far_crag = Crag.create!(
          name: 'Far Crag',
          latitude: 0,
          longitude: 0,
          city: 'Far City',
          rocks: ['granite'],
          user: users(:normal_user)
        )
        get guide_books_around_api_v1_crag_url(far_crag), headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 0, json_response.size
      end

      test 'should get areas around' do
        new_area = Area.create!(name: 'New Area Around', user: users(:normal_user))
        AreaCrag.create!(area: new_area, crag: crags(:orpierre))

        get areas_around_api_v1_crag_url(@crag), headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)

        assert_equal 1, json_response.size
        assert_equal 'New Area Around', json_response.first['name']
      end

      test 'should return empty areas around if none' do
        far_crag = Crag.create!(
          name: 'Far Crag for Area',
          latitude: 10,
          longitude: 10,
          city: 'Far City',
          rocks: ['granite'],
          user: users(:normal_user)
        )
        get areas_around_api_v1_crag_url(far_crag), headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 0, json_response.size
      end

      test 'should get geo_json' do
        get geo_json_api_v1_crags_url, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 'FeatureCollection', json_response['type']
        assert json_response.key?('features')
        assert json_response['features'].size >= 2
      end

      test 'should get geo_json with minimalistic param' do
        get geo_json_api_v1_crags_url, params: { minimalistic: true }, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 'FeatureCollection', json_response['type']
        assert json_response['features'].size >= 2
      end

      test 'should filter geo_json by climbing_style' do
        get geo_json_api_v1_crags_url, params: { climbing_style: 'multi_pitch' }, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 1, json_response['features'].size
        assert_equal 'Orpierre - Quiquillon', json_response['features'].first['properties']['name']
      end

      test 'should filter geo_json by altitude' do
        get geo_json_api_v1_crags_url, params: { altitude: 700, altitudeSwitch: 'above' }, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 2, json_response['features'].size

        get geo_json_api_v1_crags_url, params: { altitude: 700, altitudeSwitch: 'below' }, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 0, json_response['features'].size
      end

      test 'should filter geo_json by orientations' do
        get geo_json_api_v1_crags_url, params: { orientations: ['south'] }, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 2, json_response['features'].size

        get geo_json_api_v1_crags_url, params: { orientations: ['north'] }, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 0, json_response['features'].size
      end

      test 'should filter geo_json by grade_range' do
        assert CragRoute.count >= 4

        get geo_json_api_v1_crags_url, params: { gradeRange: [45, 52] }, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 0, json_response['features'].size

        get geo_json_api_v1_crags_url, params: { gradeRange: [40, 52] }, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 2, json_response['features'].size
        
        get geo_json_api_v1_crags_url, params: { gradeRange: [0, 35] }, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_equal 1, json_response['features'].size
        assert_equal 'Rocher des Aures', json_response['features'].first['properties']['name']
      end

      test 'should get geo_json_around' do
        get geo_json_around_api_v1_crag_url(@crag), headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)

        assert_equal 'FeatureCollection', json_response['type']
        features = json_response['features']

        types = features.map { |f| f['properties']['type'] }.uniq
        assert_includes types, 'Crag'
        assert_includes types, 'CragSector'
        assert_includes types, 'Park'
        assert_includes types, 'Approach'
        assert_includes types, 'RockBar'

        crag_features = features.select { |f| f['properties']['type'] == 'Crag' }
        assert crag_features.any? { |f| f['properties']['id'] == @crag.id }
      end

      test 'should get geo_json_around with minimalistic param' do
        get geo_json_around_api_v1_crag_url(@crag), params: { minimalistic: true }, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)

        assert_equal 'FeatureCollection', json_response['type']
        features = json_response['features']

        park_feature = features.find { |f| f['properties']['type'] == 'Park' }
        assert_not park_feature['properties'].key?('description')
      end

      test 'should get additional_geo_json_features' do
        get additional_geo_json_features_api_v1_crags_url, params: { ids: [@crag.id] }, headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)

        assert_equal 'FeatureCollection', json_response['type']
        features = json_response['features']

        types = features.map { |f| f['properties']['type'] }.uniq
        assert_includes types, 'CragSector'
        assert_includes types, 'Park'
        assert_includes types, 'Approach'
        assert_includes types, 'RockBar'
        
        assert_not_includes types, 'Crag'
      end

      test 'should get crag guides' do
        get guides_api_v1_crag_url(@crag), headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)

        assert_equal 6, json_response.size

        types = json_response.map { |g| g['guide_type'] }.uniq
        assert_includes types, 'GuideBookPaper'
        assert_includes types, 'GuideBookPdf'
        assert_includes types, 'GuideBookWeb'

        papers = json_response.select { |g| g['guide_type'] == 'GuideBookPaper' }
        assert_equal 2, papers.size
        assert_equal 'Guide Book 2024', papers.first['guide']['name']

        pdfs = json_response.select { |g| g['guide_type'] == 'GuideBookPdf' }
        assert_equal 2, pdfs.size

        webs = json_response.select { |g| g['guide_type'] == 'GuideBookWeb' }
        assert_equal 2, webs.size
      end

      test 'should get crag photos' do
        photo = Photo.new(
          illustrable: @crag,
          user: users(:normal_user)
        )
        photo.picture.attach(
          io: File.open(Rails.root.join('test/fixtures/files/image.jpg')),
          filename: 'image.jpg',
          content_type: 'image/jpeg'
        )
        photo.save!

        get photos_api_v1_crag_url(@crag), headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
        assert_equal 1, json_response.size
      end

      test 'should get crag videos' do
        get videos_api_v1_crag_url(@crag), headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
        assert_equal 1, json_response.size
      end

      test 'should get crag articles' do
        get articles_api_v1_crag_url(@crag), headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
        assert_equal 1, json_response.size
      end

      test 'should get crag route_figures' do
        get route_figures_api_v1_crag_url(@crag), headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert json_response.key?('route_count')
      end

      test 'should get crags_around' do
        get crags_around_api_v1_crags_url,
            params: { latitude: 44.4, longitude: 5.0, distance: 100 },
            headers: @user_headers
        assert_response :success
        json_response = JSON.parse(response.body)
        assert_kind_of Array, json_response
        assert json_response.size >= 1
      end
    end
  end
end
