# frozen_string_literal: true

module Api
  module V1
    class ConversationsController < ApiController
      before_action :protected_by_session, only: %i[index show create]
      before_action :set_conversation, only: %i[show]

      def index
        @conversations = Conversation.joins(:conversation_users)
                                     .where(conversation_users: { user_id: @current_user.id })
      end

      def show
        render json: {}, status: :unauthorized if @conversation.conversation_users.where(user: @current_user).count.zero?
      end

      def create
        @conversation = Conversation.new(conversation_params)

        same_conversation = @conversation.same_conversation
        @conversation = same_conversation if same_conversation.present?

        if @conversation.save
          render 'api/v1/conversations/show'
        else
          render json: { error: @conversation.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_conversation
        @conversation = Conversation.includes(:conversation_messages)
                                    .includes(:conversation_users)
                                    .find(params[:id])
      end

      def conversation_params
        params.require(:conversation).permit(
          conversation_users_attributes: %i[id user_id]
        )
      end
    end
  end
end
