# frozen_string_literal: true

module Api
  module V1
    class ConversationMessagesController < ApiController
      before_action :protected_by_session
      before_action :set_conversation_message, except: %i[index create]
      before_action :set_conversation
      before_action :protected_by_conversation_owner
      before_action :protected_by_message_owner, except: %i[index create]

      def index
        messages = @conversation.conversation_messages.includes(:user).order(posted_at: :desc).page(params.fetch(:page, 1))
        @conversation_messages = messages.reverse || []
      end

      def show; end

      def create
        @conversation_message = ConversationMessage.new(conversation_message_params)
        @conversation_message.conversation = @conversation
        @conversation_message.user = @current_user
        if @conversation_message.save
          data = @conversation_message.show_to_json
          data[:message_status] = 'new_message'
          ActionCable.server.broadcast "conversations_#{@conversation_message.conversation_id}", data
          render 'api/v1/conversation_messages/show'
        else
          render json: { error: @conversation_message.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @conversation_message.update(conversation_message_params)
          data = @conversation_message.show_to_json
          data[:message_status] = 'edit_message'
          ActionCable.server.broadcast "conversations_#{@conversation_message.conversation_id}", data
          render 'api/v1/conversation_messages/show'
        else
          render json: { error: @conversation_message.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @conversation_message.destroy
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
        @conversation = Conversation.find params[:conversation_id]
      end

      def set_conversation_message
        @conversation_message = ConversationMessage.find params[:id]
      end

      def conversation_message_params
        params.require(:conversation_message).permit(
          :body
        )
      end
    end
  end
end
