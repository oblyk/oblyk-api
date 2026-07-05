# frozen_string_literal: true

class WordSerializer < BaseSerializer
  include AttachmentsSerializerHelper

  belongs_to :user, lazy_load_data: true

  attributes :id,
             :name,
             :app_path,
             :slug_name,
             :definition

  attribute :versions_count, if: proc { |object, params|
    params[:with_versions_count] == true ? object.versions.length : nil
  }

  attribute :history do |object|
    {
      created_at: object.created_at,
      updated_at: object.updated_at
    }
  end
end
