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

      def model
        render json: {
          label_direction: 'one_by_row',
          layout_options: GymLabelTemplate.default_layout_options,
          footer_options: GymLabelTemplate.default_footer_options,
          header_options: GymLabelTemplate.default_header_options,
          label_options: GymLabelTemplate.default_label_options,
          border_style: {
            'border-color': '#BEBEBE',
            'border-width': '0.3mm',
            'border-style': 'solid',
            'border-radius': '3mm'
          },
          font_family: 'lato',
          qr_code_position: 'none',
          label_arrangement: 'rectangular_horizontal',
          grade_style: 'tag_and_hold',
          display_points: false,
          display_openers: true,
          display_opened_at: true,
          display_name: true,
          display_description: false,
          display_anchor: false,
          display_climbing_style: true,
          display_grade: true,
          display_tag_and_hold: true,
          page_format: 'A4',
          page_direction: 'portrait'
        }, status: :ok
      end

      def print
        sector = params.fetch(:sector_id, nil)
        route_ids = params.fetch(:route_ids, nil)
        preview_routes_set = params.fetch(:preview_routes_set, nil)
        group_by = params.fetch(:group_by, nil)
        sort_by = params.fetch(:sort_by, 'grade')
        sort_direction = params.fetch(:sort_direction, 'asc') == 'asc' ? 'asc' : 'desc'
        reference = params.fetch(:reference, nil)
        routes_by_page = params.fetch(:routes_by_page, 7)&.to_i
        pages = []
        gym_routes = []

        if preview_routes_set
          gym_routes = build_preview_routes preview_routes_set
        else
          gym_routes = GymRoute.where(id: route_ids) if route_ids
          if sector
            sector = @gym.gym_sectors.find(sector)
            gym_routes = sector.gym_routes.mounted
          end
          gym_routes = gym_routes.order(min_grade_value: sort_direction) if group_by == 'anchor' || sort_by == 'grade'
          gym_routes = gym_routes.order("anchor_number #{sort_direction}, min_grade_value") if group_by == 'sector' || sort_by == 'anchor'
          gym_routes = gym_routes.joins(:gym_sector).order("gym_sectors.order #{sort_direction}, gym_sectors.name, min_grade_value") if sort_by == 'sector'
          gym_routes = gym_routes.order("opened_at #{sort_direction}") if sort_by == 'opened_at'
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

        renderer = Redcarpet::Render::HTML.new(
          no_links: true,
          no_images: true,
          hard_wrap: true
        )
        markdown = Redcarpet::Markdown.new(renderer)

        # Footer to markdown
        footer_body = @gym_label_template.footer_options['center_top']['body']
        footer_body = footer_body&.gsub('%salle%', @gym.name)
        footer_body = markdown.render footer_body

        # Header to markdown
        header_body = @gym_label_template.header_options['center']['body']
        header_body = header_body&.gsub('%salle%', @gym.name)
        header_body = markdown.render header_body

        # Convert description to markdown
        if @gym_label_template.display_description
          gym_routes.each_with_index do |gym_route, index|
            gym_routes[index][:description] = markdown.render(gym_route[:description]) if gym_route[:description].present?
          end
        end

        case group_by
        when 'anchor'
          groups = gym_routes.group_by { |gym_route| gym_route[:anchor_number] }
          groups.each do |k, routes|
            reference = @gym_label_template.footer_options['center_bottom']['body']
            reference = reference&.gsub('%type_de_groupe%', 'Relais')
            reference = reference&.gsub('%reference%', k&.to_s)
            pages << {
              order: k,
              footer_body: footer_body,
              header_body: header_body,
              reference: reference,
              routes: routes
            }
          end
        when 'sector'
          groups = gym_routes.group_by { |gym_route| gym_route[:gym_sector_id] }
          groups.each do |k, routes|
            group_sector = GymSector.find k
            reference = @gym_label_template.footer_options['center_bottom']['body']
            reference = reference&.gsub('%type_de_groupe%', 'Secteur')
            reference = reference&.gsub('%reference%', group_sector.name)
            pages << {
              order: group_sector.order,
              footer_body: footer_body,
              header_body: header_body,
              reference: reference.presence,
              routes: routes
            }
          end
        else
          page_loop = 0
          page_index = 0
          gym_routes.each do |gym_route|
            footer_reference = @gym_label_template.footer_options['center_bottom']['body']
            footer_reference = footer_reference&.gsub('%type_de_groupe%', '')
            footer_reference = footer_reference&.gsub('%reference%', reference)
            footer_reference = markdown.render footer_reference

            pages[page_index] ||= {
              order: page_index,
              footer_body: footer_body,
              header_body: header_body,
              reference: footer_reference,
              routes: []
            }
            pages[page_index][:routes] << gym_route
            page_loop += 1
            if page_loop == routes_by_page
              page_loop = 0
              page_index += 1
            end
          end
        end

        # Qrcode in footer
        if @gym_label_template.footer_options['display']
          pages.each_with_index do |page, index|
            routes_query = page[:routes].map { |route| "r[]=#{route[:id]}" }.join('&')
            uri = "#{ENV['OBLYK_APP_URL']}/grs/#{@gym.id}?#{routes_query}"
            pages[index][:footer_qrcode] = RQRCode::QRCode.new(
              uri,
              level: :l
            ).as_svg(
              viewbox: true,
              use_path: true
            )
          end
        end

        render json: {
          gym_label_template: @gym_label_template.detail_to_json,
          pages: pages,
          gym: @gym.detail_to_json
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
          footer_options: [
            :display,
            :height,
            :border,
            {
              left: %i[display type],
              right: %i[display type],
              center_top: %i[body text_align color font_size],
              center_bottom: %i[body text_align color font_size]
            }
          ],
          label_options: [
            grade: %i[width font_size font_family text_transform],
            visual: %i[width],
            information: %i[font_size font_family],
            rectangular_horizontal: %i[height],
            rectangular_vertical: [
              top: %i[height vertical_align],
              bottom: %i[height]
            ]
          ],
          header_options: [
            :display,
            :height,
            {
              left: %i[display type],
              right: %i[display type],
              center: %i[body text_align color font_size]
            }
          ],
          layout_options: %i[page_margin align_items row_gap column_gap],
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
