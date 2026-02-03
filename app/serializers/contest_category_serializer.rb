# frozen_string_literal: true

class ContestCategorySerializer
  include JSONAPI::Serializer

  belongs_to :contest

  attributes :id,
             :name,
             :description,
             :slug_name,
             :order,
             :capacity,
             :unisex,
             :registration_obligation,
             :min_age,
             :max_age,
             :under_age,
             :over_age,
             :auto_distribute,
             :waveable,
             :contest_id,
             :waves,
             :parity

  attribute :contest_participants_count do |object|
    object.contest_participants.count
  end

  attribute :contest_participants_female_count do |object|
    object.contest_participants.where(genre: :female).count
  end

  attribute :contest_participants_male_count do |object|
    object.contest_participants.where(genre: :male).count
  end

  attribute :history do |object|
    {
      created_at: object.created_at,
      updated_at: object.updated_at
    }
  end
end
