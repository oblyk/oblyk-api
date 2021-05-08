# frozen_string_literal: true

module Api
  module V1
    class PhotosController < ApiController
      before_action :protected_by_session, only: %i[create update destroy]
      before_action :set_photo, only: %i[show update destroy]
      before_action :protected_by_owner, only: %i[update destroy]

      def index
        @photos = Photo.where(id: params[:photo_ids])
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
        not_authorized if @current_user.id != @photo.user_id
      end
    end
  end
end
