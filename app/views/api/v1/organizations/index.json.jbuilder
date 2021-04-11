# frozen_string_literal: true

json.array! @organizations do |organization|
  json.partial! 'api/v1/organizations/short_detail', organization: organization
end
