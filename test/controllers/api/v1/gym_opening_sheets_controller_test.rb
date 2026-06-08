# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class GymOpeningSheetsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @sheet = gym_opening_sheets(:sheet_one)
        @archived_sheet = gym_opening_sheets(:sheet_archived)
        @admin = users(:super_admin_user)
        @admin_headers = api_headers(user: :super_admin_user)
        
        # S'assurer que l'admin a le rôle manage_opening pour cette salle
        gym_admin = @admin.gym_administrators.find_or_initialize_by(gym: @gym)
        gym_admin.roles ||= []
        gym_admin.roles << 'manage_opening' unless gym_admin.roles.include?('manage_opening')
        gym_admin.save!
      end

      test 'should get index' do
        get api_v1_gym_gym_opening_sheets_url(gym_id: @gym.id), headers: @admin_headers
        assert_response :success
        json = JSON.parse(response.body)
        assert_kind_of Array, json
      end

      test 'should get index unarchived' do
        get api_v1_gym_gym_opening_sheets_url(gym_id: @gym.id, archived: 'false'), headers: @admin_headers
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 1, json.count
        assert_equal @sheet.id, json.first['id']
      end

      test 'should show gym opening sheet' do
        get api_v1_gym_gym_opening_sheet_url(gym_id: @gym.id, id: @sheet.id), headers: @admin_headers
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @sheet.id, json['id']
      end

      test 'should create gym opening sheet' do
        assert_difference('GymOpeningSheet.count', 1) do
          post api_v1_gym_gym_opening_sheets_url(gym_id: @gym.id),
               params: {
                 gym_opening_sheet: {
                   title: 'Nouvelle fiche',
                   description: 'Description de test',
                   number_of_columns: 3
                 }
               },
               headers: @admin_headers, as: :json
        end
        assert_response :success
      end

      test 'should update gym opening sheet' do
        patch api_v1_gym_gym_opening_sheet_url(gym_id: @gym.id, id: @sheet.id),
              params: {
                gym_opening_sheet: {
                  title: 'Titre modifié'
                }
              },
              headers: @admin_headers, as: :json
        assert_response :success
        @sheet.reload
        assert_equal 'Titre modifié', @sheet.title
      end

      test 'should update cells' do
        # On initialise row_json pour que le test puisse le modifier
        @sheet.update_column :row_json, [{ 'routes' => [{}, { 'grade' => '5a' }] }]
        
        put update_cells_api_v1_gym_gym_opening_sheet_url(gym_id: @gym.id, id: @sheet.id),
            params: {
              gym_opening_sheet: {
                cells: [
                  {
                    rowIndex: 0,
                    cellIndex: 1,
                    grade: '6a',
                    hold_color: '#FF0000',
                    climbing_styles: ['slab']
                  }
                ]
              }
            },
            headers: @admin_headers, as: :json
        assert_response :no_content
        @sheet.reload
        assert_equal '6a', @sheet.row_json[0]['routes'][1]['grade']
        assert_equal '#FF0000', @sheet.row_json[0]['routes'][1]['hold_color']
        assert_equal ['slab'], @sheet.row_json[0]['routes'][1]['climbing_styles']
      end

      test 'should archive gym opening sheet' do
        put archived_api_v1_gym_gym_opening_sheet_url(gym_id: @gym.id, id: @sheet.id), headers: @admin_headers, as: :json
        assert_response :success
        @sheet.reload
        assert_not_nil @sheet.archived_at
      end

      test 'should unarchive gym opening sheet' do
        put unarchived_api_v1_gym_gym_opening_sheet_url(gym_id: @gym.id, id: @archived_sheet.id), headers: @admin_headers, as: :json
        assert_response :success
        @archived_sheet.reload
        assert_nil @archived_sheet.archived_at
      end

      test 'should destroy gym opening sheet' do
        assert_difference('GymOpeningSheet.count', -1) do
          delete api_v1_gym_gym_opening_sheet_url(gym_id: @gym.id, id: @sheet.id), headers: @admin_headers, as: :json
        end
        assert_response :no_content
      end

      test 'should print gym opening sheet' do
        # On mocke WickedPdf et render_to_string pour éviter l'erreur de template manquant et de génération de PDF en test
        pdf_mock = Minitest::Mock.new
        pdf_mock.expect :pdf_from_string, 'PDF DATA', [String]

        WickedPdf.stub :new, pdf_mock do
          # Au lieu de stubber render_to_string sur ActionController::Base,
          # on va stubber la méthode de classe New qui est utilisée dans le contrôleur.
          # gym_opening_sheets_controller.rb:31: ActionController::Base.new.render_to_string
          base_mock = Minitest::Mock.new
          base_mock.expect :render_to_string, '<html></html>', [Hash]
          
          ActionController::Base.stub :new, base_mock do
            get print_api_v1_gym_gym_opening_sheet_url(gym_id: @gym.id, id: @sheet.id), headers: @admin_headers
            assert_response :success
            assert_equal 'application/pdf', response.content_type
            assert_equal 'PDF DATA', response.body
          end
        end
      end
    end
  end
end
