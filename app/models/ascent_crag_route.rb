# frozen_string_literal: true

require 'csv'

class AscentCragRoute < Ascent
  include ActivityFeedable

  belongs_to :crag_route
  has_one :crag, through: :crag_route

  delegate :latitude, to: :crag_route
  delegate :longitude, to: :crag_route

  delegate :feed_parent_id, to: :user
  delegate :feed_parent_type, to: :user
  delegate :feed_parent_object, to: :user

  validates :roping_status, inclusion: { in: RopingStatus::LIST }
  validates :climbing_type, inclusion: { in: Climb::CRAG_LIST }
  validates :note, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 6 }, allow_blank: true

  before_validation :historize_ascents
  before_validation :historize_grade_gap

  after_save :update_crag_route!
  after_create :delete_tick_in_list
  after_destroy :update_crag_route!

  def summary_to_json(with_user: false)
    detail_to_json(with_user: with_user)
  end

  def detail_to_json(with_user: false)
    detail = {
      id: id,
      ascent_status: ascent_status,
      roping_status: roping_status,
      hardness_status: hardness_status,
      attempt: attempt,
      crag_route_id: crag_route_id,
      sections: sections,
      height: height,
      note: note,
      comment: comment,
      sections_count: sections_count,
      max_grade_value: max_grade_value,
      min_grade_value: min_grade_value,
      max_grade_text: max_grade_text,
      min_grade_text: min_grade_text,
      released_at: released_at,
      private_comment: private_comment,
      sections_done: sections_done,
      crag_route: crag_route.summary_to_json,
      crag: crag.summary_to_json,
      ascent_users: ascent_users.map { |ascent_user| { id: ascent_user.id, user: ascent_user.user.summary_to_json(with_avatar: false) } },
      history: {
        created_at: created_at,
        updated_at: updated_at
      }
    }
    detail[:user] = user.summary_to_json if with_user
    detail
  end

  def self.to_csv
    CSV.generate(headers: true, encoding: 'utf-8', col_sep: "\t") do |csv|
      csv << [
        'Crag Route : Name',
        'Crag Route : Grade',
        'Crag Route : Height',
        'Crag Route : Climbing type',
        'Ascent : Status',
        'Ascent - Roping status',
        'Ascent - Attempt',
        'Ascent - Released at',
        'Ascent - My note',
        'Ascent - My comment',
        'Ascent - Grade value',
        'Crag - Name',
        'Crag - City',
        'Crag - Region',
        'Crag - Country',
        'Crag - Latitude',
        'Crag - Longitude',
        'Crag - Rocks',
        'Crag Sector - Name'
      ]
      all.includes(crag_route: :crag_sector).includes(crag_route: :crag).find_each do |ascent|
        route = ascent.crag_route
        crag = route.crag
        grade = route.sections.map { |section| section['grade'] }.join(', ')
        roping = Climb.ropable?(route.climbing_type) ? ascent.roping_status : nil
        released_at = ascent.ascent_status != 'project' ? ascent.released_at : nil
        grad_value = route.sections.map { |section| section['grade_value'] }.join(', ')
        csv << [
          route.name,
          grade,
          route.height,
          route.climbing_type,
          ascent.ascent_status,
          roping,
          ascent.attempt,
          released_at,
          ascent.note,
          ascent.comment,
          grad_value,
          crag.name,
          crag.city,
          crag.region,
          crag.country,
          crag.latitude,
          crag.longitude,
          crag.rocks,
          route.crag_sector&.name
        ]
      end
    end
  end

  private

  def update_crag_route!
    crag_route.update_form_ascents!
  end

  def historize_ascents
    self.height = crag_route.height
    self.climbing_type = crag_route.climbing_type

    # Sections
    sections = []
    crag_route.sections.each_with_index do |section, index|
      next unless selected_sections.include? index

      sections << {
        index: index,
        height: section['height'],
        grade: section['grade'],
        grade_value: section['grade_value']
      }
    end
    self.sections = sections
  end

  def historize_grade_gap
    max_grade_value = Grade::MIN_GRADE
    max_grade_text = ''
    min_grade_value = Grade::MAX_GRADE
    min_grade_text = ''

    sections.each do |section|
      max_grade_text = section['grade'] if section['grade_value'] > max_grade_value
      max_grade_value = section['grade_value'] if section['grade_value'] > max_grade_value

      min_grade_text = section['grade'] if section['grade_value'] < min_grade_value
      min_grade_value = section['grade_value'] if section['grade_value'] < min_grade_value
    end

    self.max_grade_text = max_grade_text
    self.min_grade_text = min_grade_text
    self.max_grade_value = max_grade_value
    self.min_grade_value = min_grade_value
    self.sections_count = sections.count
  end

  def delete_tick_in_list
    tick = TickList.find_by crag_route: crag_route, user: user
    tick&.destroy
  end
end
