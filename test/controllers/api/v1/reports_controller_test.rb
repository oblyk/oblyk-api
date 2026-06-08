# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class ReportsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = users(:normal_user)
        @organization = organizations(:oblyk_orga)
        @user_headers = api_headers(user: :normal_user)
        @public_headers = api_access_token_headers
      end

      test 'should create report when authenticated' do
        assert_difference('Report.count', 1) do
          post api_v1_reports_url,
               params: {
                 report: {
                   reportable_type: 'Crag',
                   reportable_id: crags(:rocher_des_aures).id,
                   body: 'Ceci est un signalement pour une falaise.',
                   report_from_url: 'https://oblyk.org/crags/rocher-des-aures'
                 }
               },
               headers: @user_headers,
               as: :json
        end
        assert_response :success
      end

      test 'should set default reportable to Organization if not provided' do
        assert_difference('Report.count', 1) do
          post api_v1_reports_url,
               params: {
                 report: {
                   body: 'Signalement sans reportable spécifié.'
                 }
               },
               headers: @user_headers,
               as: :json
        end
        assert_response :success
        
        report = Report.last
        assert_equal 'Organization', report.reportable_type
        assert_equal @organization.id, report.reportable_id
      end

      test 'should fail to create report when not authenticated' do
        assert_no_difference('Report.count') do
          post api_v1_reports_url,
               params: {
                 report: {
                   body: 'Signalement par un utilisateur non connecté.'
                 }
               },
               headers: @public_headers,
               as: :json
        end
        assert_response :unauthorized
      end

      test 'should return unprocessable entity when params are invalid' do
        post api_v1_reports_url,
             params: {
               report: {
                 reportable_type: 'Ascent', # Ascent n'est pas dans la liste REPORTABLE_LIST de Report
                 body: 'Type de signalement non autorisé.'
               }
             },
             headers: @user_headers,
               as: :json
        assert_response :unprocessable_entity
      end
    end
  end
end
