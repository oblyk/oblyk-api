# frozen_string_literal: true

class GymChain < ApplicationRecord
  include Slugable
  include AttachmentResizable
  include StripTagable

  has_secure_token :api_access_token

  has_one_attached :logo
  has_one_attached :banner
  has_many :gym_chain_gyms
  has_many :gyms, through: :gym_chain_gyms
  has_many :gym_chain_administrators
  has_many :users, through: :gym_chain_administrators

  validates :logo, blob: { content_type: :image }, allow_nil: true
  validates :banner, blob: { content_type: :image }, allow_nil: true
  validates :name, presence: true

  def summary_to_json
    Rails.cache.fetch("#{cache_key_with_version}/summary_gym_chain", expires_in: 28.days) do
      {
        id: id,
        name: name,
        slug_name: slug_name,
        description: description,
        public_chain: public_chain,
        attachments: {
          banner: attachment_object(banner),
          logo: attachment_object(logo)
        }
      }
    end
  end

  def detail_to_json
    summary_to_json.merge(
      {
        history: {
          created_at: created_at,
          updated_at: updated_at
        }
      }
    )
  end

  def delete_summary_cache
    Rails.cache.delete("#{cache_key_with_version}/summary_gym_chain")
  end

  private

  def search_indexes
    [
      { value: name, column_names: %i[name] }
    ]
  end
end
