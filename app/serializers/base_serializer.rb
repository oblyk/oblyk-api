# frozen_string_literal: true

class BaseSerializer
  include JSONAPI::Serializer

  def self.include_attribute(params, attribute)
    type = class_name.gsub('Serializer', '').to_sym
    params[:include_attributes]&.fetch(type, [])&.include?(attribute)
  end
end
