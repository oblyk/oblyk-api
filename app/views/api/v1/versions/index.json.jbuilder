# frozen_string_literal: true

json.versions_count @versions.length
json.versions do
  json.array! @versions do |version|
    json.event version.event
    json.created_at version.created_at
    json.changes version.changeset
    user = User.find_by id: version.whodunnit
    if user
      json.user do
        json.uuid user.uuid
        json.name user.full_name
        json.slug_name user.slug_name
      end
    end
  end
end
