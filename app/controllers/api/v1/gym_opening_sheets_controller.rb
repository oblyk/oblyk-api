# frozen_string_literal: true

module Api
  module V1
    class GymOpeningSheetsController < ApiController
      include Gymable

      before_action -> { can? GymRole::MANAGE_OPENING }
      before_action :set_gym_opening_sheet, except: %i[index create]

      def index
        gym_opening_sheets = @gym.gym_opening_sheets
                                 .select(:id, :title, :description, :archived_at, :gym_id, :created_at, :updated_at)
                                 .includes(:gym)

        gym_opening_sheets = if params.fetch(:archived, 'true') == 'true'
                               gym_opening_sheets.archived
                             else
                               gym_opening_sheets.unarchived
                             end

        gym_opening_sheets = gym_opening_sheets.order(created_at: :desc)
        render json: gym_opening_sheets.map(&:summary_to_json), status: :ok
      end

      def show
        render json: @gym_opening_sheet.detail_to_json, status: :ok
      end

      def print
        pdf_html = ActionController::Base.new.render_to_string(
          template: 'api/v1/gym_opening_sheet/print.pdf.erb',
          locals: { gym_opening_sheet: @gym_opening_sheet }
        )
        pdf = WickedPdf.new.pdf_from_string(pdf_html)
        send_data pdf, filename: "#{@gym_opening_sheet.title}.pdf"
      end

      def create
        gym_opening_sheet = GymOpeningSheet.new(gym_opening_sheet_params)
        gym_opening_sheet.gym_id = @gym.id
        gym_opening_sheet.gym_sector_ids = params[:gym_opening_sheet].fetch(:gym_sector_ids, nil)
        gym_opening_sheet.build_row_json

        if gym_opening_sheet.save
          render json: gym_opening_sheet.detail_to_json, status: :ok
        else
          render json: { error: gym_opening_sheet.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @gym_opening_sheet.update gym_opening_sheet_params
          render json: @gym_opening_sheet.detail_to_json, status: :ok
        else
          render json: { error: @gym_opening_sheet.errors }, status: :unprocessable_entity
        end
      end

      def update_cells
        gym_opening_sheet_cells_params[:cells].each do |cell|
          @gym_opening_sheet.row_json[cell[:rowIndex]]['routes'][cell[:cellIndex]]['grade'] = cell[:grade]
          @gym_opening_sheet.row_json[cell[:rowIndex]]['routes'][cell[:cellIndex]]['hold_color'] = cell[:hold_color]
          @gym_opening_sheet.row_json[cell[:rowIndex]]['routes'][cell[:cellIndex]]['climbing_styles'] = cell[:climbing_styles] || []
        end
        @gym_opening_sheet.save
        head :no_content
      end

      def destroy
        if @gym_opening_sheet&.destroy
          head :no_content
        else
          render json: { error: @gym_opening_sheet.errors }, status: :unprocessable_entity
        end
      end

      def archived
        if @gym_opening_sheet.archive!
          render json: @gym_opening_sheet.detail_to_json, status: :ok
        else
          render json: { error: @gym_opening_sheet.errors }, status: :unprocessable_entity
        end
      end

      def unarchived
        if @gym_opening_sheet.unarchive!
          render json: @gym_opening_sheet.detail_to_json, status: :ok
        else
          render json: { error: @gym_opening_sheet.errors }, status: :unprocessable_entity
        end
      end

      private

      def gym_opening_sheet_params
        params.require(:gym_opening_sheet).permit(
          :title,
          :description,
          :number_of_columns
        )
      end

      def gym_opening_sheet_cells_params
        params.require(:gym_opening_sheet).permit(
          cells: [
            :rowIndex,
            :cellIndex,
            :grade,
            :hold_color,
            climbing_styles: []
          ]
        )
      end

      def set_gym_opening_sheet
        @gym_opening_sheet = @gym.gym_opening_sheets.find params[:id]
      end
    end
  end
end
