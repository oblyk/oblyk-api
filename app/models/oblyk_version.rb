# frozen_string_literal: true

class OblykVersion
  def self.index(versions)
    {
      versions_count: versions.length,
      versions: versions.map { |version| OblykVersion.version_detail(version) }
    }
  end

  def self.version_detail(version)
    json = {
      event: version.event,
      created_at: version.created_at,
      changes: version.changeset
    }
    user = User.find_by id: version.whodunnit
    if user
      json[:user] = {
        uuid: user.uuid,
        name: user.full_name,
        slug_name: user.slug_name
      }
    end
    json
  end
end
