# frozen_string_literal: true

class ColorSystemLine < ApplicationRecord
  belongs_to :color_system

  default_scope { order(:order) }

  def summary_to_json
    detail_to_json
  end

  def detail_to_json
    {
      id: id,
      hex_color: hex_color,
      order: order
    }
  end
end
