# frozen_string_literal: true

module Api
  module V1
    class GymCommunityLabelsController < ApiController
      include Gymable
      before_action -> { can? GymRole::MANAGE_OPENING }

      def disc_chart
        sheet_references = []
        sector_id = params.fetch(:sector_id, nil)
        route_ids = if sector_id.present?
                      GymRoute.mounted.where(gym_sector_id: sector_id).pluck(:id)
                    else
                      params.fetch(:ids, []).map(&:to_i)
                    end

        gym_routes = GymRoute.joins(gym_sector: :gym_space)
                             .where(id: route_ids)
                             .where(gym_spaces: { gym_id: @gym.id })
                             .order(:min_grade_value)

        routes = gym_routes.map do |route|
          qr_svg = RQRCode::QRCode.new(route.short_app_path, level: :l).as_svg(viewbox: true, use_path: true)
          sheet_reference = if route.anchor_number.present?
                              route.anchor_number
                            elsif route.gym_sector.name.size <= 2
                              route.gym_sector.name
                            else
                              route.gym_sector.order
                            end
          sheet_references << sheet_reference
          {
            sheet_reference: sheet_reference,
            hold_colors: route.hold_colors,
            grade_to_s: route.grade_to_s,
            openers: route.gym_openers.map { |opener| { name: opener.name } },
            qr_svg: qr_svg
          }
        end

        routes.sort_by! { |route| route[:sheet_reference] }

        pdf_io = DiscChartService.new(routes).generate_pdf

        # Sheet name
        sheet_references.uniq!
        sheet_references = if sheet_references.size <= 5
                             sheet_references.join(', ')
                           else
                             "#{sheet_references.first(5).join(', ')}..."
                           end

        filename = "Disque de voie - #{sheet_references} - #{I18n.l(Date.current, format: :iso)} - #{@gym.name}.pdf"
        response.headers['X-Filename'] = filename

        send_data pdf_io, filename: filename
      end
    end
  end
end
