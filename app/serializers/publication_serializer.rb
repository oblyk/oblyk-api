# frozen_string_literal: true

class PublicationSerializer
  include JSONAPI::Serializer

  has_many :publication_attachments
  belongs_to :publishable, polymorphic: true
  belongs_to :author, serializer: :publication_author

  attributes :id,
             :app_path,
             :body,
             :published_at,
             :draft,
             :likes_count,
             :comments_count,
             :publishable_id,
             :publishable_type,
             :publishable_subject,
             :last_updated_at,
             :attachables_count,
             :attachable_types_count,
             :generated,
             :pined_at,
             :viewed

  attribute :history do |object|
    {
      created_at: object.created_at,
      updated_at: object.updated_at
    }
  end

  attribute :add_this_week do |object|
    object.published_at.present? && object.published_at > Time.current.beginning_of_week
  end

  attribute :published_week_at,
            if: proc { |record| record.generated && %w[new_crag_routes new_photo new_video].include?(record.publishable_subject) } do |object|
    object.published_at.beginning_of_week
  end
end
