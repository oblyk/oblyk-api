# frozen_string_literal: true

module Api
  module V1
    class ConversationsController < ApiController
      before_action :protected_by_session
      before_action :set_conversation, only: %i[show]

      def index
        conversations = Conversation.joins(:conversation_users)
                                    .includes(conversation_messages: :user, conversation_users: { user: { avatar_attachment: :blob } })
                                    .where(conversation_users: { user_id: @current_user.id })
                                    .order(last_message_at: :desc)
        render json: conversations.map(&:summary_to_json), status: :ok
      end

      def show
        if @conversation.conversation_users.includes(:user).where(user: @current_user).count.zero?
          render json: {}, status: :unauthorized
        else
          render json: @conversation.detail_to_json, status: :ok
        end
      end

      def create
        @conversation = Conversation.new(conversation_params)

        same_conversation = @conversation.same_conversation
        @conversation = same_conversation if same_conversation.present?

        if @conversation.save
          render json: @conversation.detail_to_json, status: :ok
        else
          render json: { error: @conversation.errors }, status: :unprocessable_entity
        end
      end

      def read
        conversation_user = ConversationUser.find_by user: @current_user, conversation_id: params[:id]
        conversation_user.read!
        render json: { last_read_at: conversation_user.last_read_at }, status: :ok
      end

      private

      def set_conversation
        @conversation = Conversation.includes(conversation_messages: :user, conversation_users: { user: { avatar_attachment: :blob } })
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
