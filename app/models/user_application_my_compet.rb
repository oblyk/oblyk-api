# frozen_string_literal: true

class UserApplicationMyCompet < UserApplication
  validates :ffme_licence_number, presence: true
  validates :ffme_licence_number, numericality: { only_integer: true }

  before_validation :normalise_ffme_licence_number

  private

  def normalise_ffme_licence_number
    self.ffme_licence_number = ffme_licence_number&.strip
    self.ffme_licence_number = nil if ffme_licence_number.blank?
  end
end
