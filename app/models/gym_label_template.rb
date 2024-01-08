# frozen_string_literal: true

class GymLabelTemplate < ApplicationRecord
  include Archivable

  LABEL_DIRECTION_LIST = %w[one_by_row two_by_row three_by_row four_by_row circular].freeze
  QR_CODE_POSITION_LIST = %w[in_label footer none].freeze
  PAGE_FORMAT_LIST = %w[A1 A2 A3 A4 A5 A6 free].freeze
  PAGE_DIRECTION_LIST = %w[portrait landscape free].freeze
  LABEL_ARRANGEMENT_LIST = %w[rectangular_horizontal rectangular_vertical].freeze
  GRADE_STYLE_LIST = %w[none tag_and_hold diagonal_label].freeze

  belongs_to :gym

  validates :name, presence: true
  validates :label_direction, inclusion: { in: LABEL_DIRECTION_LIST }
  validates :font_family, inclusion: { in: GymLabelFont::FONTS.map { |font| font.first.to_s } }
  validates :qr_code_position, inclusion: { in: QR_CODE_POSITION_LIST }
  validates :page_format, inclusion: { in: PAGE_FORMAT_LIST }
  validates :page_direction, inclusion: { in: PAGE_DIRECTION_LIST }
  validates :label_arrangement, inclusion: { in: LABEL_ARRANGEMENT_LIST }
  validates :grade_style, inclusion: { in: GRADE_STYLE_LIST }

  def summary_to_json
    {
      id: id,
      name: name,
      label_direction: label_direction,
      layout_options: layout_options,
      border_style: border_style,
      font_family: font_family,
      font: GymLabelFont::FONTS[font_family.to_sym],
      qr_code_position: qr_code_position,
      label_arrangement: label_arrangement,
      grade_style: grade_style,
      display_points: display_points,
      display_openers: display_openers,
      display_opened_at: display_opened_at,
      display_name: display_name,
      display_description: display_description,
      display_anchor: display_anchor,
      display_climbing_style: display_climbing_style,
      display_grade: display_grade,
      display_tag_and_hold: display_tag_and_hold,
      page_format: page_format,
      page_direction: page_direction,
      archived_at: archived_at,
      gym: {
        id: gym.id,
        slug_name: gym.slug_name
      }
    }
  end

  def detail_to_json
    summary_to_json.merge(
      {
        history: {
          created_at: created_at,
          updated_at: updated_at
        }
      }
    )
  end
end
