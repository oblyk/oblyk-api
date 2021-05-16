# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user(request.params['token'].split(' ').last)
      logger.add_tags 'ActionCable', current_user.id
    end

    private

    def find_verified_user(token)
      User.find_by(ws_token: token) || reject_unauthorized_connection
    end
  end
end
