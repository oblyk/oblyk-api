# frozen_string_literal: true

module Api
  module V1
    class GuideBookPdfsController < ApiController
      before_action :protected_by_super_admin, only: %i[destroy]
      before_action :protected_by_session, only: %i[create update]
      before_action :set_guide_book_pdf, only: %i[show update destroy]

      def index
        @guide_book_pdfs = GuideBookPdf.where crag_id: params[:crag_id]
      end

      def show; end

      def create
        @guide_book_pdf = GuideBookPdf.new(guide_book_pdf_params)
        @guide_book_pdf.user = @current_user
        if @guide_book_pdf.save
          render 'api/v1/guide_book_pdfs/show'
        else
          render json: { error: @guide_book_pdf.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @guide_book_pdf.update(guide_book_pdf_params)
          render 'api/v1/guide_book_pdfs/show'
        else
          render json: { error: @guide_book_pdf.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @guide_book_pdf.delete
          render json: {}, status: :ok
        else
          render json: { error: @guide_book_pdf.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_guide_book_pdf
        @guide_book_pdf = GuideBookPdf.find params[:id]
      end

      def guide_book_pdf_params
        params.require(:guide_book_pdf).permit(
          :name,
          :author,
          :description,
          :publication_year,
          :crag_id,
          :pdf_file
        )
      end
    end
  end
end
