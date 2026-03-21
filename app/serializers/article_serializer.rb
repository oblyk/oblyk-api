# frozen_string_literal: true

class ArticleSerializer < BaseSerializer
  include AttachmentsSerializerHelper

  has_many :crags, lazy_load_data: true
  has_many :guide_book_papers, lazy_load_data: true
  belongs_to :author, serializer: UserSerializer

  attributes :id,
             :slug_name,
             :name,
             :description,
             :views,
             :comments_count,
             :likes_count,
             :published_at,
             :app_path,
             :author_id

  attribute :published, &:published?

  attribute :body, if: proc { |object, params|
    params[:with_body] == true ? object.body : nil
  }

  def self.cover_attachment(object)
    object.attachment_object(object.cover)
  end

  def self.avatar_attachment(object)
    cover_attachment(object)
  end
end
