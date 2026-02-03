# frozen_string_literal: true

class GymSerializer
  include JSONAPI::Serializer
  include AttachmentsSerializerHelper

  has_many :gym_options

  attributes :id,
             :name,
             :slug_name,
             :app_path,
             :app_first_spaces_path,
             :optimal_spaces_path,
             :description,
             :email,
             :phone_number,
             :web_site,
             :latitude,
             :longitude,
             :code_country,
             :country,
             :city,
             :big_city,
             :region,
             :address,
             :postal_code,
             :sport_climbing,
             :bouldering,
             :pan,
             :fun_climbing,
             :training_space,
             :boulder_ranking,
             :pan_ranking,
             :sport_climbing_ranking,
             :three_d_camera_position,
             :representation_type,
             :gym_type,
             :gym_billing_account_id,
             :follows_count

  attribute :administered, &:administered?
  attribute :have_guide_book, &:guide_book?

  attribute :gym_spaces_count do |object|
    object.gym_spaces.size
  end

  def self.logo_attachment(object)
    object.attachment_object(object.logo)
  end

  def self.avatar_attachment(object)
    logo_attachment(object)
  end

  def self.banner_attachment(object)
    object.attachment_object(object.banner)
  end
end
