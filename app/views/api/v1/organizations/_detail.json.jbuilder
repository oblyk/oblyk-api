# frozen_string_literal: true

json.partial! 'api/v1/organizations/short_detail', organization: organization

json.organization_users do
  json.array! organization.organization_users do |organization_user|
    json.id organization_user.id
    json.user do
      json.partial! 'api/v1/users/short_detail', user: organization_user.user
    end
  end
end

json.history do
  json.extract! organization, :created_at, :updated_at
end

