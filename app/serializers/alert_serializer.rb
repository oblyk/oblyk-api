# frozen_string_literal: true

class AlertSerializer < BaseSerializer
  has_one :alertable, polymorphic: true

  attributes :id,
             :description,
             :alert_type,
             :alerted_at,
             :alertable_type,
             :alertable_id

  attribute :history do |object|
    {
      created_at: object.created_at,
      updated_at: object.updated_at
    }
  end
end
