# frozen_string_literal: true

module Api
  module V1
    class PhotosController < ApiController
      before_action :protected_by_super_admin, only: %i[destroy]
      before_action :protected_by_session, only: %i[create update]
      before_action :set_photo, only: %i[show update destroy]

      def index
        @photos = Photo.where(
          illustrable_type: params[:illustrable_type],
          illustrable_id: params[:illustrable_id]
        )
      end

      def show; end

      def create
        @photo = Photo.new(photo_params)
        @photo.user = @current_user
        if @photo.save
          render 'api/v1/photos/show'
        else
          render json: { error: @photo.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @photo.update(photo_params)
          render 'api/v1/photos/show'
        else
          render json: { error: @photo.errors }, status: :unprocessable_entity
        end
      end

      def destroy
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
    end
  end
end
