# frozen_string_literal: true

class LikeSerializer
  include JSONAPI::Serializer

  belongs_to :likeable, polymorphic: true

  attributes :id,
             :likeable_type,
             :likeable_id

  attribute :likeable_likes_count do |object|
    object.likeable.likes_count
  end
end
