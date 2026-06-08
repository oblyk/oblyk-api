# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class GymLabelTemplatesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @gym = gyms(:my_gym)
        @template = gym_label_templates(:one)
        @admin = users(:other_user)
        GymAdministrator.create!(
          user: @admin,
          gym: @gym,
          requested_email: @admin.email,
          roles: [GymRole::MANAGE_OPENING, GymRole::MANAGE_SPACE]
        )
        @admin_headers = api_headers(user: :other_user)
      end

      test 'should get index' do
        get api_v1_gym_gym_label_templates_url(gym_id: @gym.id), headers: @admin_headers
        assert_response :success
      end

      test 'should show template' do
        get api_v1_gym_gym_label_template_url(gym_id: @gym.id, id: @template.id), headers: @admin_headers
        assert_response :success
      end

      test 'should create template' do
        assert_difference('GymLabelTemplate.count') do
          post api_v1_gym_gym_label_templates_url(gym_id: @gym.id),
               params: {
                 gym_label_template: {
                   name: 'New Template',
                   label_direction: 'one_by_row',
                   font_family: 'lato',
                   qr_code_position: 'in_label',
                   page_format: 'A4',
                   page_direction: 'portrait',
                   label_arrangement: 'rectangular_horizontal',
                   grade_style: 'none',
                   label_options: GymLabelTemplate.default_label_options,
                   layout_options: GymLabelTemplate.default_layout_options,
                   footer_options: GymLabelTemplate.default_footer_options,
                   header_options: GymLabelTemplate.default_header_options
                 }
               },
               as: :json,
               headers: @admin_headers
        end
        assert_response :success
      end

      test 'should update template' do
        patch api_v1_gym_gym_label_template_url(gym_id: @gym.id, id: @template.id),
              params: { gym_label_template: { name: 'Updated Name' } },
              as: :json,
              headers: @admin_headers
        assert_response :success
        @template.reload
        assert_equal 'Updated Name', @template.name
      end

      test 'should archive template' do
        put archived_api_v1_gym_gym_label_template_url(gym_id: @gym.id, id: @template.id), headers: @admin_headers
        assert_response :success
        @template.reload
        assert_not_nil @template.archived_at
      end

      test 'should unarchive template' do
        @template.archive!
        put unarchived_api_v1_gym_gym_label_template_url(gym_id: @gym.id, id: @template.id), headers: @admin_headers
        assert_response :success
        @template.reload
        assert_nil @template.archived_at
      end

      test 'should destroy template' do
        assert_difference('GymLabelTemplate.count', -1) do
          delete api_v1_gym_gym_label_template_url(gym_id: @gym.id, id: @template.id), headers: @admin_headers
        end
        assert_response :success
      end

      test 'should print template' do
        sector = gym_sectors(:my_gym_sector)
        get print_api_v1_gym_gym_label_template_url(gym_id: @gym.id, id: @template.id),
            params: { sector_id: sector.id },
            headers: @admin_headers
        assert_response :success
      end
    end
  end
end
