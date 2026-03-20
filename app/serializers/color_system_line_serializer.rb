# frozen_string_literal: true

class ColorSystemLineSerializer < BaseSerializer
  belongs_to :color_system

  attributes :id,
             :hex_color,
             :order
end
