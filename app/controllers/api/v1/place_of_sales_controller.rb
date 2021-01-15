# frozen_string_literal: true

module Api
  module V1
    class PlaceOfSalesController < ApiController
      before_action :protected_by_session, only: %i[create update destroy]
      before_action :set_place_of_sale, only: %i[show update destroy]
      before_action :set_guide_book_paper, only: %i[index show update create destroy]
      before_action :protected_by_owner, only: %i[update destroy]

      def index
        @place_of_sales = @guide_book_paper.place_of_sales
      end

      def show; end

      def create
        @place_of_sale = PlaceOfSale.new(place_of_sale_params)
        @place_of_sale.user = @current_user
        @place_of_sale.guide_book_paper = @guide_book_paper
        if @place_of_sale.save
          render 'api/v1/place_of_sales/show'
        else
          render json: { error: @place_of_sale.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @place_of_sale.update(place_of_sale_params)
          render 'api/v1/place_of_sales/show'
        else
          render json: { error: @place_of_sale.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @place_of_sale.delete
          render json: {}, status: :ok
        else
          render json: { error: @place_of_sale.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_guide_book_paper
        @guide_book_paper = GuideBookPaper.find params[:guide_book_paper_id]
      end

      def set_place_of_sale
        @place_of_sale = PlaceOfSale.find params[:id]
      end

      def place_of_sale_params
        params.require(:place_of_sale).permit(
          :name,
          :url,
          :description,
          :latitude,
          :longitude,
          :code_country,
          :country,
          :postal_code,
          :city,
          :region,
          :address
        )
      end

      def protected_by_owner
        not_authorized if @current_user.id != @place_of_sale.user_id
      end
    end
  end
end
