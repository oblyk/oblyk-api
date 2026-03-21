# frozen_string_literal: true

class BaseSerializer
  include JSONAPI::Serializer

  def self.include_attribute(params, attribute, object_key)
    params[:include_attributes]&.fetch(object_key, [])&.include?(attribute)
  end
end
