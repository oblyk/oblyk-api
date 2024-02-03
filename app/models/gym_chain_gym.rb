# frozen_string_literal: true

class GymChainGym < ApplicationRecord
  belongs_to :gym
  belongs_to :gym_chain

  def summary_to_json
    {
      id: id,
      gym_id: gym_id,
      gym_chain_id: gym_chain_id
    }
  end

  def detail_to_json
    summary_to_json
  end
end
