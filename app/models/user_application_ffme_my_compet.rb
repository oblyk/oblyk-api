# frozen_string_literal: true

class UserApplicationFfmeMyCompet < UserApplication
  validates :ffme_licence_number, presence: true
end
