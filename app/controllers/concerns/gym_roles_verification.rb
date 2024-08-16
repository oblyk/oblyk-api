# frozen_string_literal: true

module GymRolesVerification
  extend ActiveSupport::Concern

  private

  def gym_team_user?
    login? unless @current_user
    return false unless @current_user
    return false unless @gym

    @gym.gym_administrators.exists?(user_id: @current_user.id)
  end

  def can?(role)
    roles = @current_user.gym_administrators.find_by(gym: @gym)&.roles || []
    return if roles.include?(role)

    render json: {
      error: 'You do not have the necessary rights to access this resource',
      code_error: 'right_required'
    }, status: :forbidden
  end
end
