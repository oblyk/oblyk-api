# frozen_string_literal: true

class CragSectorSerializer
  include JSONAPI::Serializer

  attributes :id, :name
end
