# frozen_string_literal: true

class AscentUserSerializer
  include JSONAPI::Serializer

  belongs_to :user
end
