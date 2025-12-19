# frozen_string_literal: true

module Api
  module V1
    class PhotosController < ApiController
      include ImageParamsConvert

      before_action :protected_by_session, only: %i[create update destroy]
      before_action :set_photo, only: %i[show update destroy]
      before_action :protected_by_owner, only: %i[update destroy]

      def index
        photos = Photo.where(id: params[:photo_ids])
        render json: photos.map(&:summary_to_json), status: :ok
      end

      def show
        render json: @photo.detail_to_json, status: :ok
      end

      def create
        params[:photo][:picture] = convert_image_on_params %i[photo picture]
        @photo = Photo.new(photo_params)
        @photo.user = @current_user
        if @photo.save
          render json: @photo.detail_to_json, status: :ok
        else
          render json: { error: @photo.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @photo.update(photo_params)
          render json: @photo.detail_to_json, status: :ok
        else
          render json: { error: @photo.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        unless @photo.destroyable?
          render json: { error: { base: ['un_destroyable'] } }, status: :unprocessable_entity
          return
        end

        if @photo.destroy
          render json: {}, status: :ok
        else
          render json: { error: @photo.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_photo
        @photo = Photo.find params[:id]
      end

      def photo_params
        params.require(:photo).permit(
          :illustrable_type,
          :illustrable_id,
          :description,
          :exif_model,
          :exif_make,
          :source,
          :alt,
          :copyright_by,
          :copyright_nc,
          :copyright_nd,
          :picture
        )
      end

      def protected_by_owner
        forbidden if @current_user.id != @photo.user_id
      end
    end
  end
end
