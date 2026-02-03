# frozen_string_literal: true

class ColorSystemLineSerializer
  include JSONAPI::Serializer

  belongs_to :color_system

  attributes :id,
             :hex_color,
             :order
end
