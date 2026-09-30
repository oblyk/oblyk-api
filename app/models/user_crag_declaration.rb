# frozen_string_literal: true

class UserCragDeclaration < ApplicationRecord
  belongs_to :crag
  belongs_to :user
  belongs_to :guide_book_paper, optional: true

  DECLARATION_SYSTEMS = %w[honour guide_book_secret_question]

  validates :declaration_system, presence: true
  validates :declaration_system, inclusion: { in: DECLARATION_SYSTEMS }
  validates :crag_id, uniqueness: { scope: :user_id, case_sensitive: false }
  validates :equivalent_level, inclusion: { in: GradeProtectionLevel::LEVELS }

  before_validation :set_equivalent_level
  before_validation :set_default_attributes, on: :create

  def set_equivalent_level
    self.equivalent_level = 2 if declaration_system == "honour"
    self.equivalent_level = 3 if declaration_system == "guide_book_secret_question"
  end

  private

  def set_default_attributes
    self.declared_at = Time.zone.now
  end
end
