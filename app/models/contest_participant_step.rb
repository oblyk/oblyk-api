# frozen_string_literal: true

class ContestParticipantStep < ApplicationRecord
  belongs_to :contest_participant
  belongs_to :contest_stage_step
end
