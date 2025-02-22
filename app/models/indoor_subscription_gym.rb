# frozen_string_literal: true

class IndoorSubscriptionGym < ApplicationRecord
  belongs_to :indoor_subscription
  belongs_to :gym
end
