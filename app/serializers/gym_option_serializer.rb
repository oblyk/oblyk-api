# frozen_string_literal: true

class GymOptionSerializer < BaseSerializer
  attributes :id,
             :option_type,
             :start_date,
             :end_date,
             :remaining_unit,
             :unlimited_unit

  attribute :activated, &:activated?
  attribute :credited, &:credited?
  attribute :usable, &:usable?
end
