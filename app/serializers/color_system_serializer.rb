# frozen_string_literal: true

class ColorSystemSerializer < BaseSerializer
  has_many :color_system_lines, lazy_load_data: true

  attributes :id,
             :colors_mark
end
