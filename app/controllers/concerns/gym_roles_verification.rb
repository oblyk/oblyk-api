# frozen_string_literal: true

module GymRolesVerification
  extend ActiveSupport::Concern

  private

  def can?(role)
    roles = @current_user.gym_administrators.find_by(gym: @gym)&.roles || []
    return if roles.include?(role)

    render json: {
      error: 'You do not have the necessary rights to access this resource',
      code_error: 'right_required'
    }, status: :forbidden
  end
end
