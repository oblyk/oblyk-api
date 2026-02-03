# frozen_string_literal: true

module Api
  module V1
    class PublicationAttachmentsController < ApiController
      include GymRolesVerification

      before_action :protected_by_session, only: %i[create destroy create_bulk]
      before_action :set_publication
      before_action :set_publication_attachment, only: %i[show update destroy]
      before_action :protected_by_owner, only: %i[update destroy create_bulk create]

      def index
        render json: serialized_publication_attachment(@publication.publication_attachments), status: :ok
      end

      def show
        render json: serialized_publication_attachment(@publication_attachment), status: :ok
      end

      def create
        publication_attachment = @publication.publication_attachments.find_or_initialize_by(
          attachable_type: publication_attachment_params[:attachable_type],
          attachable_id: publication_attachment_params[:attachable_id],
          publication_id: @publication.id
        )
        if publication_attachment.save
          render json: serialized_publication_attachment(publication_attachment), status: :ok
        else
          render json: { error: publication_attachment.errors }, status: :unprocessable_entity
        end
      end

      def create_bulk
        publication_attachments_params[:publication_attachments].each do |attachment|
          @publication.publication_attachments << PublicationAttachment.find_or_initialize_by(
            attachable_type: attachment[:attachable_type],
            attachable_id: attachment[:attachable_id],
            publication_id: @publication.id
          )
        end

        if @publication.save
          render json: serialized_publication(@publication), status: :ok
        else
          render json: { error: @publication.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @publication.update publication_attachment_params
          render json: serialized_publication(@publication), status: :ok
        else
          render json: { error: @publication.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @publication_attachment.destroy
          @publication.reload
          render json: serialized_publication(@publication), status: :ok
        else
          render json: { error: @publication_attachment.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_publication
        @publication = Publication.find params[:publication_id]
      end

      def set_publication_attachment
        @publication_attachment = @publication.publication_attachments.find params[:id]
      end

      def serialized_publication(publication)
        options = { include: [:publication_attachments, :publishable, :author, 'publication_attachments.attachable'], params: serializer_params }
        serializer PublicationSerializer, publication, options
      end

      def serialized_publication_attachment(publication)
        serializer(
          PublicationAttachmentSerializer,
          publication,
          {
            include: [:attachable],
            params: serializer_params
          }
        )
      end

      def serializer_params
        {
          include_attachments: {
            Crag: %i[avatar cover],
            Gym: %i[avatar logo],
            User: %i[avatar],
            GymSpace: %i[avatar],
            GymRoute: %i[thumbnail],
            GuideBookPaper: %i[avatar],
            Article: %i[avatar],
            Contest: %i[banner],
            Photo: %i[picture]
          }
        }
      end

      def publication_attachment_params
        params.require(:publication_attachment).permit(
          :attachable_type,
          :attachable_id
        )
      end

      def publication_attachments_params
        params.require(:publication_attachments)
        params.permit(publication_attachments: %i[attachable_type attachable_id])
      end

      def protected_by_owner
        case @publication.publishable_type
        when 'Gym'
          @gym = @publication.publishable
          forbidden unless gym_team_user?
        when 'User'
          forbidden unless @publication.publishable == @current_user
        end
      end
    end
  end
end
