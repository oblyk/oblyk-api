# frozen_string_literal: true

module Api
  module V1
    class GymLabelTemplatesController < ApiController
      include Gymable

      before_action :set_gym_label_template, only: %i[show print update destroy archived unarchived]
      before_action -> { can? GymRole::MANAGE_SPACE }, except: %i[index show]

      def index
        gym_label_templates = case params.fetch(:with_archived, 'false')
                              when 'true'
                                @gym.gym_label_templates
                              else
                                @gym.gym_label_templates.unarchived
                              end
        render json: gym_label_templates.order(:archived_at, :name).map(&:summary_to_json), status: :ok
      end

      def show
        render json: @gym_label_template.detail_to_json, status: :ok
      end

      def print
        sector = params.fetch(:sector_id, nil)
        route_ids = params.fetch(:route_ids, nil)
        preview_routes_set = params.fetch(:preview_routes_set, nil)

        gym_routes = if route_ids
                       GymRoute.where(id: route_ids)
                               .order(:min_grade_value)
                     elsif sector
                       sector = @gym.gym_sectors.find(sector)
                       sector.gym_routes.mounted.order(:min_grade_value)
                     elsif preview_routes_set
                       build_preview_routes preview_routes_set
                     end

        # Qrcode in footer
        footer_qrcode = nil
        if @gym_label_template.qr_code_position == 'footer'
          routes_query = gym_routes.map { |route| "r[]=#{route[:id]}" }.join('&')
          uri = "#{ENV['OBLYK_APP_URL']}/grs/#{@gym.id}?#{routes_query}"
          footer_qrcode = RQRCode::QRCode.new(
            uri,
            level: :l
          ).as_svg(
            viewbox: true,
            use_path: true
          )
        end

        gym_routes = gym_routes.map(&:summary_to_json) unless preview_routes_set

        # Qrcode in label
        if @gym_label_template.qr_code_position == 'in_label'
          gym_routes.each_with_index do |gym_route, index|
            gym_routes[index][:qrcode] = RQRCode::QRCode.new(
              gym_route[:short_app_path],
              level: :l
            ).as_svg(
              viewbox: true,
              use_path: true
            )
          end
        end

        render json: {
          gym_label_template: @gym_label_template.detail_to_json,
          gym_routes: gym_routes,
          gym: @gym.detail_to_json,
          footer_qrcode: footer_qrcode
        }, status: :ok
      end

      def create
        @gym_label_template = GymLabelTemplate.new(gym_label_template_params)
        @gym_label_template.gym = @gym

        if @gym_label_template.save
          render json: @gym_label_template.detail_to_json, status: :ok
        else
          render json: { error: @gym_label_template.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @gym_label_template.update(gym_label_template_params)
          render json: @gym_label_template.detail_to_json, status: :ok
        else
          render json: { error: @gym_label_template.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        @gym_label_template.destroy
        head :no_content
      end

      def archived
        if @gym_label_template.archive!
          render json: @gym_label_template.detail_to_json, status: :ok
        else
          render json: { error: @gym_label_template.errors }, status: :unprocessable_entity
        end
      end

      def unarchived
        if @gym_label_template.unarchive!
          render json: @gym_label_template.detail_to_json, status: :ok
        else
          render json: { error: @gym_label_template.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_gym_label_template
        @gym_label_template = @gym.gym_label_templates.find params[:id]
      end

      def gym_label_template_params
        params.require(:gym_label_template).permit(
          :name,
          :label_direction,
          :font_family,
          :qr_code_position,
          :label_arrangement,
          :grade_style,
          :display_points,
          :display_openers,
          :display_opened_at,
          :display_name,
          :display_description,
          :display_anchor,
          :display_climbing_style,
          :display_grade,
          :display_tag_and_hold,
          :page_format,
          :page_direction,
          layout_options: %i[page-margin],
          border_style: %i[border-style border-color border-width border-radius]
        )
      end

      def build_preview_routes(set)
        routes = [
          {
            sets: %w[simple multi_pitch],
            id: 'a',
            name: 'Nom voie 1',
            climbing_type: 'sport_climbing',
            description: 'Une description sur la voie',
            short_app_path: preview_short_path('a'),
            openers: [
              { name: 'Simon' }, { name: 'Léa' }
            ],
            opened_at: Date.current,
            hold_colors: ['#ffcc00'],
            tag_colors: ['#ffcc00'],
            sections: [{ grade: '5a', styles: %w[technical] }],
            grade_to_s: '5a',
            points: 100,
            anchor_number: 1
          },
          {
            sets: %w[simple],
            id: 'b',
            name: 'Cotation complex',
            climbing_type: 'sport_climbing',
            description: nil,
            short_app_path: preview_short_path('b'),
            openers: [
              { name: 'Simon' }
            ],
            opened_at: Date.current,
            hold_colors: ['#0055d4'],
            tag_colors: %w[#0055d4 #ab37c8],
            sections: [{ grade: '6a+/b', styles: %w[physics resistance] }],
            grade_to_s: '6a+/b',
            points: 150,
            anchor_number: 1
          },
          {
            sets: ['multi_pitch'],
            id: 'c',
            name: 'Deux longueurs',
            climbing_type: 'sport_climbing',
            description: 'Voie de deux longeurs',
            short_app_path: preview_short_path('c'),
            openers: [
              { name: 'Simon' }
            ],
            opened_at: Date.current,
            hold_colors: ['#0055d4'],
            tag_colors: %w[#0055d4 #ab37c8],
            sections: [{ grade: '6a', styles: %w[physics] }, { grade: '6c+', styles: %w[resistance] }],
            grade_to_s: '6a, 6c',
            points: 250,
            anchor_number: 1
          },
          {
            sets: %w[simple multi_pitch],
            id: 'd',
            name: 'Cotation complex',
            climbing_type: 'sport_climbing',
            description: nil,
            short_app_path: preview_short_path('d'),
            openers: [
              { name: 'Simon' }
            ],
            opened_at: Date.current,
            hold_colors: ['#ab37c8'],
            tag_colors: ['#ab37c8'],
            sections: [{ grade: '6c', styles: %w[boulder] }],
            grade_to_s: '6c',
            points: 200,
            anchor_number: 1
          },
          {
            sets: %w[simple multi_pitch],
            id: 'e',
            name: 'Voie avec 3 ouvreurs',
            climbing_type: 'sport_climbing',
            description: nil,
            short_app_path: preview_short_path('e'),
            openers: [
              { name: 'Simon' }, { name: 'Léa' }, { name: 'Pierre' }
            ],
            opened_at: Date.current,
            hold_colors: %w[#ff0000 #000000],
            tag_colors: ['#ff0000'],
            sections: [{ grade: '7a+', styles: %w[endurance] }],
            grade_to_s: '7a+',
            points: 300,
            anchor_number: 1
          }
        ]
        routes.filter { |route| route[:sets].include?(set) }
      end

      def preview_short_path(id)
        "#{ENV['OBLYK_APP_URL']}/gr/#{@gym.id}-#{id}"
      end
    end
  end
end
