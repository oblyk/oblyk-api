# frozen_string_literal: true

class ColorSystemSerializer
  include JSONAPI::Serializer

  has_many :color_system_lines

  attributes :id,
             :colors_mark
end
