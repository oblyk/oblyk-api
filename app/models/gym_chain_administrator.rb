# frozen_string_literal: true

class GymChainAdministrator < ApplicationRecord
  belongs_to :user
  belongs_to :gym_chain

  def summary_to_json
    {
      id: id,
      user_id: user_id,
      gym_chain_id: gym_chain_id
    }
  end

  def detail_to_json
    summary_to_json
  end
end
