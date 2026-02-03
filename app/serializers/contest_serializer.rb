# frozen_string_literal: true

class ContestSerializer
  include JSONAPI::Serializer
  include AttachmentsSerializerHelper

  belongs_to :gym
  has_many :contest_categories
  has_many :contest_stages
  has_many :championships
  has_many :contest_waves
  has_one :ffme_contest

  attributes :id,
             :name,
             :slug_name,
             :app_path,
             :app_admin_path,
             :description,
             :gym_id,
             :start_date,
             :end_date,
             :subscription_start_date,
             :subscription_end_date,
             :subscription_closed_at,
             :combined_ranking_type,
             :draft,
             :authorise_public_subscription,
             :private,
             :hide_results,
             :total_capacity,
             :categorization_type,
             :archived_at,
             :team_contest,
             :participant_per_team,
             :optional_gender,
             :remaining_places

  attribute :one_day_event, &:one_day_event?
  attribute :finished, &:finished?
  attribute :ongoing, &:ongoing?
  attribute :coming, &:coming?
  attribute :beginning_is_in_past, &:beginning_is_in_past?
  attribute :subscription_opened, &:subscription_opened?
  attribute :authentification_opened, &:authentification_opened?

  attribute :contest_participants_count do |object|
    object.contest_participants.count
  end

  attribute :ffme_contest_id do |object|
    object.ffme_contest&.id
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
