# frozen_string_literal: true

class Color
  def self.black_or_white_rgb(color)
    return color if color == 'inherit'

    if color.first == '#'
      r, g, b = Color.hex_to_rgb color
    else
      r, g, b = color.delete('rgb()').split(',').map { |rgb| rgb.strip.to_i }
    end

    brightness = (r * 299 + g * 587 + b * 114) / 1000

    if brightness > 128
      'rgb(0,0,0)'
    else
      'rgb(255,255,255)'
    end
  end

  def self.hex_to_rgb(hex)
    hex = hex.delete('#')

    r = hex[0..1].to_i(16)
    g = hex[2..3].to_i(16)
    b = hex[4..5].to_i(16)

    [r, g, b]
  end
end
