# frozen_string_literal: true

module Gymable
  extend ActiveSupport::Concern

  included do
    before_action :protected_by_session
    before_action :set_gym
    before_action :protected_by_gym_administrator
  end

  private

  def set_gym
    @gym = Gym.find params[:gym_id]
  end

  def protected_by_gym_administrator
    return if @current_user.super_admin

    not_authorized unless @gym.gym_administrators.where(user_id: @current_user.id).exist?
  end
end
