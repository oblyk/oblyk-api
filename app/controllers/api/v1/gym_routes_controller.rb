# frozen_string_literal: true

module Api
  module V1
    class GymRoutesController < ApiController
      include Gymable
      include ImageParamsConvert

      skip_before_action :protected_by_session, only: %i[show index paginated ascents comments]
      skip_before_action :protected_by_gym_administrator, only: %i[show index paginated ascents comments]
      before_action :set_gym_space, except: %i[add_picture similar_sectors add_thumbnail dismount mount dismount_collection mount_collection ascents delete_picture comments opening_sheet_collection]
      before_action :set_gym_sector, except: %i[index show similar_sectors add_picture add_thumbnail dismount mount dismount_collection mount_collection ascents delete_picture comments opening_sheet_collection]
      before_action :set_gym_route, only: %i[show similar_sectors update destroy add_picture add_thumbnail dismount mount ascents delete_picture comments]
      before_action -> { can? GymRole::MANAGE_OPENING }, except: %i[index paginated show similar_sectors ascents comments]

      def index
        group_by = params.fetch(:group_by, nil)
        order_by = params.fetch(:order_by, nil)
        direction = params.fetch(:direction, 'asc') == 'asc' ? 'ASC' : 'DESC'
        dismounted = params.fetch(:dismounted, false)
        route_ids = params.fetch(:route_ids, nil)

        if group_by == 'sector'
          sectors = if @gym_sector.present?
                      @gym_sector
                    elsif @gym_space.present?
                      GymSector.where(gym_space: @gym_space).reorder("`order` #{direction}")
                    else
                      GymSector.joins(:gym_space).where(gym_spaces: { gym_id: @gym.id }).reorder("`order` #{direction}")
                    end
          routes_json = { sectors: [] }
          sectors.each do |sector|
            routes = dismounted ? sector.gym_routes.dismounted : sector.gym_routes.mounted
            routes = routes.order('anchor_number, min_grade_value')
            routes_json[:sectors] << {
              sector: sector.summary_to_json,
              routes: routes.map(&:summary_to_json)
            }
          end
          render json: routes_json, status: :ok
        else
          routes = if @gym_sector.present?
                     GymRoute.where(gym_sector: @gym_sector)
                   elsif @gym_space.present?
                     GymRoute.joins(:gym_sector).where(gym_sectors: { gym_space: @gym_space })
                   elsif route_ids
                     GymRoute.where(id: route_ids)
                   else
                     GymRoute.joins(:gym_space).where(gym_spaces: { gym: @gym })
                   end

          # Mount or dismount
          routes = dismounted ? routes.dismounted : routes.mounted

          # Order
          routes = routes.order("opened_at #{direction}") if order_by == 'opened_at'
          routes = routes.order("max_grade_value #{direction}") if order_by == 'grade'
          routes = routes.order("level_index #{direction}") if order_by == 'level'
          routes = routes.includes(:sector).order("sectors.name #{direction}") if order_by == 'sector'

          # group by
          case group_by
          when 'opened_at'
            opened_routes = group_by_opened_at(routes)
            render json: { opened_at: opened_routes.map { |opened_route| { opened_at: opened_route[0], routes: opened_route[1][:routes].map(&:summary_to_json) } } }, status: :ok
          when 'grade'
            grade_routes = group_by_grade(routes)
            render json: { grade: grade_routes.map { |grade_route| { grade: grade_route[0], routes: grade_route[1][:routes].map(&:summary_to_json) } } }, status: :ok
          when 'level'
            level_routes = group_by_level(routes)
            render json: { level: level_routes.map { |level_route| { name: level_route[1][:name], colors: level_route[1][:colors], tag_color: level_route[1][:tag_color], hold_color: level_route[1][:hold_color], routes: level_route[1][:routes].map(&:summary_to_json) } } }, status: :ok
          when 'point'
            if direction == 'DESC'
              render json: routes.sort_by { |route| -(route.calculated_point || 0) }.map(&:summary_to_json), status: :ok
            else
              render json: routes.sort_by { |route| route.calculated_point || 0 }.map(&:summary_to_json), status: :ok
            end
          else
            render json: routes.map(&:summary_to_json), status: :ok
          end
        end
      end

      def paginated
        order_by = params.fetch(:order_by, nil)
        route_ids = params.fetch(:route_ids, nil)
        direction = params.fetch(:direction, 'asc') == 'asc' ? 'ASC' : 'DESC'
        dismounted = params.fetch(:dismounted, 'false') == 'true'

        routes = if @gym_sector.present?
                   @gym_sector.gym_routes
                 elsif @gym_space.present?
                   @gym_space.gym_routes
                 elsif route_ids.present?
                   @gym.gym_routes.where(ids: route_ids)
                 else
                   @gym.gym_routes.joins(gym_sector: :gym_space).where(gym_spaces: { draft: false, archived_at: nil })
                 end

        routes = dismounted ? routes.dismounted : routes.mounted

        routes = routes.includes(
          :gym_openers,
          :gym_sector,
          :gym_space,
          :gym,
          gym: :gym_levels,
          thumbnail_attachment: :blob,
          gym_route_cover: { picture_attachment: :blob }
        )

        routes = case order_by
                 when 'sector'
                   routes.joins(:gym_sector).reorder("gym_sectors.order #{direction}, gym_sectors.name, gym_sectors.id, gym_routes.anchor_number, gym_routes.min_grade_value, gym_routes.id")
                 when 'opened_at'
                   routes.reorder("gym_routes.opened_at #{direction}, gym_routes.id")
                 when 'grade'
                   routes.reorder("gym_routes.min_grade_value #{direction}, gym_routes.id")
                 when 'level'
                   routes.reorder("gym_routes.level_index #{direction}, gym_routes.id")
                 when 'point'
                   routes.reorder("gym_routes.points #{direction}, gym_routes.id")
                 when 'ascents_count'
                   routes.reorder("gym_routes.ascents_count #{direction}, gym_routes.id")
                 when 'likes_count'
                   routes.reorder("gym_routes.likes_count #{direction}, gym_routes.id")
                 when 'comments_count'
                   routes.reorder("gym_routes.all_comments_count #{direction}, gym_routes.id")
                 else
                   routes
                 end

        routes = routes.page(params.fetch(:page, 1))
                       .map(&:summary_to_json)

        # Map user ascents onto routes liste
        routes = GymRouteAscentsMapper.new(routes, @current_user).map_ascents if login?

        render json: routes, status: :ok
      end

      def print
        gym_routes = GymRoute.where(id: params[:ids])
                             .order(:min_grade_value)

        pdf_html = ActionController::Base.new.render_to_string(
          template: 'api/v1/gym_routes/print.pdf.erb',
          locals: { gym_routes: gym_routes }
        )
        pdf = WickedPdf.new.pdf_from_string(pdf_html)
        send_data pdf, filename: "Fiche de voie - #{I18n.l(Date.current, format: :iso)} - #{@gym.name}.pdf"
      end

      def export
        gym_routes = GymRoute.includes(gym_sector: :gym_space)
                             .where(id: params[:ids])
                             .order(:opened_at)

        csv_data = CSV.generate(
          headers: true,
          col_sep: "\t"
        ) do |csv|
          csv << %w[hold_colors tag_colors grade points height name description openers opened_at sector space anchor nb_ascents nb_comments nb_likes nb_videos url short_url]
          gym_routes.each do |gym_route|
            csv << [
              gym_route.hold_colors&.join(', '),
              gym_route.tag_colors&.join(', '),
              gym_route.grade_to_s,
              gym_route.points_to_s,
              gym_route.height,
              gym_route.name,
              gym_route.description,
              gym_route.gym_openers&.map(&:name)&.join(', '),
              gym_route.opened_at,
              gym_route.gym_sector.name,
              gym_route.gym_sector.gym_space.name,
              gym_route.anchor_number,
              gym_route.ascents_count,
              gym_route.comments_count,
              gym_route.likes_count,
              gym_route.videos_count,
              gym_route.app_path,
              gym_route.short_app_path
            ]
          end
        end
        send_data(
          csv_data,
          filename: "oblyk-export-#{DateTime.now.strftime('%Y-%m-%d %H:%M')}.csv",
          type: :csv
        )
      end

      def show
        route = @gym_route.detail_to_json
        route = GymRouteAscentsMapper.new(route, @current_user).map_ascents if login?

        render json: route, status: :ok
      end

      def similar_sectors
        sectors = @gym_route.gym_sector.gym_space.gym_sectors
        render json: sectors.map(&:summary_to_json), status: :ok
      end

      def ascents
        ascent_gym_routes = @gym_route.ascent_gym_routes
        render json: ascent_gym_routes.map(&:summary_to_json), status: :ok
      end

      def create
        @gym_route = GymRoute.new(gym_route_params)
        @gym_route.gym_sector = @gym_sector
        if @gym_route.save
          render json: @gym_route.detail_to_json, status: :ok
        else
          render json: { error: @gym_route.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @gym_route.update(gym_route_params)
          @gym_route.delete_summary_cache
          render json: @gym_route.detail_to_json, status: :ok
        else
          render json: { error: @gym_route.errors }, status: :unprocessable_entity
        end
      end

      def add_picture
        new_gym_route_cover_id = picture_params.fetch(:gym_route_cover_id, nil)

        params[:gym_route][:gym_route_cover][:picture] = convert_image_on_params(%i[gym_route gym_route_cover picture]) if params[:gym_route].try(:[], :gym_route_cover)&.try(:[], :picture).present?
        # If change picture or used other picture already saved
        if new_gym_route_cover_id
          route_with_same_covers = GymRoute.where(gym_route_cover_id: new_gym_route_cover_id)
          # if route already has a picture
          if @gym_route.gym_route_cover_id && route_with_same_covers.count == 1 && @gym_route.gym_route_cover_id != new_gym_route_cover_id.to_i
            @gym_route.gym_route_cover.picture.purge # delete attachment
            @gym_route.gym_route_cover.destroy
          end
          @gym_route.gym_route_cover_id = new_gym_route_cover_id

        else # if use new picture freshly downloaded
          # if route already has a picture
          if @gym_route.gym_route_cover_id
            route_with_same_covers = GymRoute.where(gym_route_cover_id: @gym_route.gym_route_cover_id)
            if route_with_same_covers.count == 1 # if the route is the only one to use this picture
              @gym_route.gym_route_cover.picture.purge # delete attachment
              @gym_route.gym_route_cover.destroy
            end
          end
          @gym_route.gym_route_cover = GymRouteCover.new(picture: picture_params[:gym_route_cover][:picture])
        end

        # Render success or errors
        if @gym_route.save
          render json: @gym_route.detail_to_json, status: :ok
        else
          render json: { error: @gym_route.errors }, status: :unprocessable_entity
        end
      end

      def add_thumbnail
        if params[:gym_route][:thumbnail_position]
          thumbnail_position = JSON.parse params[:gym_route][:thumbnail_position]
          @gym_route.thumbnail_position = thumbnail_position
        end
        if @gym_route.update(thumbnail_params)
          render json: @gym_route.detail_to_json, status: :ok
        else
          render json: { error: @gym_route.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @gym_route.destroy
          render json: {}, status: :ok
        else
          render json: { error: @gym_route.errors }, status: :unprocessable_entity
        end
      end

      def dismount
        if @gym_route.dismount!
          render json: {}, status: :ok
        else
          render json: { error: @gym_route.errors }, status: :unprocessable_entity
        end
      end

      def delete_picture
        @gym_route.thumbnail = nil
        @gym_route.gym_route_cover.destroy if @gym_route.gym_route_cover && @gym_route.gym_route_cover.gym_routes.count == 1
        @gym_route.gym_route_cover = nil
        if @gym_route.save
          render json: {}, status: :ok
        else
          render json: { error: @gym_route.errors }, status: :unprocessable_entity
        end
      end

      def mount
        if @gym_route.mount!
          render json: {}, status: :ok
        else
          render json: { error: @gym_route.errors }, status: :unprocessable_entity
        end
      end

      def dismount_collection
        @gym.gym_routes.where(id: params[:route_ids]).each(&:dismount!)
        head :no_content
      end

      def mount_collection
        @gym.gym_routes.where(id: params[:route_ids]).each(&:mount!)
        head :no_content
      end

      def opening_sheet_collection
        gym_opening_sheet = GymOpeningSheet.new opening_sheet_params
        gym_opening_sheet.gym = @gym
        gym_opening_sheet.build_row_json

        if gym_opening_sheet.save
          render json: gym_opening_sheet.summary_to_json, status: :ok
        else
          render json: { error: gym_opening_sheet.errors }, status: :unprocessable_entity
        end
      end

      def comments
        comments = []
        @gym_route.comments.each do |comment|
          comments << comment
        end
        @gym_route.ascent_gym_routes.where('comments_count > 0').each do |ascent|
          comments << ascent.ascent_comment
        end
        comments = comments.sort_by(&:created_at)
        render json: comments.map(&:summary_to_json), status: :ok
      end

      private

      def group_by_sector(sectors, dismount)
        groups = []
        sectors.each do |sector|
          routes = dismount ? sector.gym_routes.dismounted : sector.gym_routes.mounted
          groups << {
            sector: sector,
            routes: routes
          }
        end
        groups
      end

      def group_by_opened_at(routes)
        dates = {}
        routes.each do |route|
          date = route.opened_at.strftime '%Y-%m-%d'
          dates[date] = dates[date] || { opened_at: date, routes: [] }
          dates[date][:routes] << route
        end
        dates
      end

      def group_by_grade(routes)
        grades = {}
        routes.each do |route|
          next if route.max_grade_value.blank?

          grade = route.max_grade_value
          grades[grade] = grades[grade] || { grade: grade, routes: [] }
          grades[grade][:routes] << route
        end
        grades
      end

      def group_by_level(routes)
        levels = {}
        routes.each do |route|
          next unless route.level_index

          levels[route.level_index] = levels[route.level_index] || {
            name: route.level_index,
            colors: [route.level_color],
            tag_color: true,
            hold_color: false,
            routes: []
          }
          levels[level][:routes] << route
        end
        levels
      end

      def set_gym_space
        @gym_space = GymSpace.find_by(id: params[:gym_space_id]) if params[:gym_space_id].present?
      end

      def set_gym_sector
        @gym_sector = GymSector.find_by id: params[:gym_sector_id]
      end

      def set_gym_route
        @gym_route = GymRoute.find params[:id]
      end

      def gym_route_params
        params.require(:gym_route).permit(
          :name,
          :height,
          :description,
          :climbing_type,
          :openers,
          :polyline,
          :points,
          :opened_at,
          :gym_sector_id,
          :anchor_number,
          :level_index,
          :level_length,
          :level_color,
          gym_opener_ids: [],
          sections: [:climbing_type, :description, :grade, :height, { styles: [] }],
          hold_colors: %i[],
          tag_colors: %i[]
        )
      end

      def picture_params
        params.require(:gym_route).permit(
          :gym_route_cover_id,
          gym_route_cover: %i[picture]
        )
      end

      def thumbnail_params
        params.require(:gym_route).permit(
          :thumbnail
        )
      end

      def opening_sheet_params
        params.require(:gym_opening_sheet).permit(
          :title,
          :description,
          :number_of_columns,
          gym_route_ids: %i[]
        )
      end
    end
  end
end
