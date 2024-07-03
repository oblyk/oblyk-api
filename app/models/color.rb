# frozen_string_literal: true

class Color
  def self.black_or_white_rgb(color)
    r, g, b = color.delete('rgb()').split(',').map { |rgb| rgb.strip.to_i }
    brightness = (r * 299 + g * 587 + b * 114) / 1000

    if brightness > 128
      'rgb(0,0,0)'
    else
      'rgb(255,255,255)'
    end
  end
end
