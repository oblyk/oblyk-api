# frozen_string_literal: true

class GymLabelTemplate < ApplicationRecord
  include Archivable

  LABEL_DIRECTION_LIST = %w[one_by_row two_by_row three_by_row four_by_row circular].freeze
  QR_CODE_POSITION_LIST = %w[in_label footer none].freeze
  PAGE_FORMAT_LIST = %w[A1 A2 A3 A4 A5 A6 free].freeze
  PAGE_DIRECTION_LIST = %w[portrait landscape free].freeze
  LABEL_ARRANGEMENT_LIST = %w[rectangular_horizontal rectangular_vertical].freeze
  GRADE_STYLE_LIST = %w[none tag_and_hold diagonal_label circle].freeze

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
      label_options: label_options,
      layout_options: layout_options,
      footer_options: footer_options,
      header_options: header_options,
      border_style: border_style,
      font_family: font_family,
      font: GymLabelFont::FONTS[font_family.to_sym],
      fonts: fonts,
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

  def fonts
    font_families = []
    font_families << font_family.to_sym
    font_families << label_options['grade']['font_family'].to_sym
    font_families << label_options['information']['font_family'].to_sym
    font_families.uniq
    fonts = []
    font_families.each do |font|
      fonts << GymLabelFont::FONTS[font.to_sym]
    end
    fonts
  end

  def self.default_footer_options
    {
      display: true,
      height: '20mm',
      border: 'none',
      left: {
        display: false,
        type: 'logo'
      },
      right: {
        display: true,
        type: 'QrCode'
      },
      center_top: {
        body: "Découvre le topo de **%salle%**\net suis ta progression sur Oblyk.org !",
        text_align: 'right',
        color: '#000000',
        font_size: '14pt'
      },
      center_bottom: {
        body: '%type_de_groupe% **%reference%**',
        text_align: 'right',
        color: '#000000',
        font_size: '12pt'
      }
    }
  end

  def self.default_header_options
    {
      display: false,
      height: '20mm',
      left: {
        display: true,
        type: 'logo'
      },
      right: {
        display: false,
        type: 'QrCode'
      },
      center: {
        body: 'Fiche de voie',
        text_align: 'center',
        color: '#000000',
        font_size: '14pt'
      }
    }
  end

  def self.default_label_options
    {
      grade: {
        width: '18mm',
        font_size: '25pt',
        font_family: 'lato',
        text_transform: 'lowercase'
      },
      visual: {
        width: '16mm'
      },
      information: {
        font_size: '14pt',
        font_family: 'lato'
      },
      rectangular_horizontal: {
        height: '27mm'
      },
      rectangular_vertical: {
        top: {
          height: '27mm',
          vertical_align: 'center'
        },
        bottom: {
          height: '20mm'
        }
      }
    }
  end

  def self.default_layout_options
    {
      align_items: 'center',
      page_margin: '10mm 10mm 10mm 10mm',
      row_gap: '3mm',
      column_gap: '3mm'
    }
  end
end
