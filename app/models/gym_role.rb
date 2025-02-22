# frozen_string_literal: true

class GymRole
  MANAGE_TEAM_MEMBER = 'manage_team_member'
  MANAGE_OPENING = 'manage_opening'
  MANAGE_OPENER = 'manage_opener'
  MANAGE_SPACE = 'manage_space'
  MANAGE_GYM = 'manage_gym'
  MANAGE_SUBSCRIPTION = 'manage_subscription'

  LIST = [
    MANAGE_TEAM_MEMBER,
    MANAGE_OPENING,
    MANAGE_OPENER,
    MANAGE_SPACE,
    MANAGE_GYM,
    MANAGE_SUBSCRIPTION
  ].freeze
end
