# frozen_string_literal: true

module Api
  module V1
    class ConversationMessagesController < ApiController
      before_action :protected_by_session, only: %i[create update destroy]
      before_action :set_conversation_message, only: %i[update destroy]
      before_action :set_conversation, only: %i[create]
      before_action :protected_by_conversation_owner, only: %i[create]
      before_action :protected_by_message_owner, only: %i[update destroy]

      def create
        @conversation_message = ConversationMessage.new(conversation_message_params)
        @conversation_message.user = @current_user
        if @conversation_message.save
          render 'api/v1/conversation_messages/show'
        else
          render json: { error: @conversation_message.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @conversation_message.update(conversation_message_params)
          render 'api/v1/conversation_messages/show'
        else
          render json: { error: @conversation_message.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @conversation_message.delete
          render json: {}, status: :ok
        else
          render json: { error: @conversation_message.errors }, status: :unprocessable_entity
        end
      end

      private

      def protected_by_conversation_owner
        render json: {}, status: :unauthorized if @conversation.conversation_users.where(user: @current_user).count.zero?
      end

      def protected_by_message_owner
        render json: {}, status: :unauthorized if @conversation_message.user != @current_user
      end

      def set_conversation
        @conversation = Conversation.find conversation_message_params[:conversation_id]
      end

      def set_conversation_message
        @conversation_message = ConversationMessage.find params[:id]
      end

      def conversation_message_params
        params.require(:conversation_message).permit(
          :body,
          :conversation_id
        )
      end
    end
  end
end
