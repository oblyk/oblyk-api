# frozen_string_literal: true

class Author < ApplicationRecord
  include StripTagable
  include AttachmentResizable

  has_one_attached :cover

  belongs_to :user

  validates :description, :name, presence: true

  def summary_to_json
    detail_to_json
  end

  def detail_to_json
    {
      id: id,
      name: name,
      description: description,
      user_id: user_id,
      attachments: {
        cover: attachment_object(cover)
      }
    }
  end
end
