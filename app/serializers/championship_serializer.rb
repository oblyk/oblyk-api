# frozen_string_literal: true

class ChampionshipSerializer < BaseSerializer
  include AttachmentsSerializerHelper

  belongs_to :gym
  has_many :contests, lazy_load_data: true

  attributes :id,
             :name,
             :slug_name,
             :description,
             :gym_id,
             :combined_ranking_type,
             :archived_at

  attribute :contests_count do |object|
    object.contests.size
  end

  attribute :history do |object|
    {
      created_at: object.created_at,
      updated_at: object.updated_at
    }
  end

  def self.banner_attachment(object)
    object.attachment_object(object.banner)
  end

  def self.avatar_attachment(object)
    banner_attachment(object)
  end
end
