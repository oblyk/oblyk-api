# frozen_string_literal: true

class OblykVersion
  def self.index(versions)
    {
      versions_count: versions.length,
      versions: versions.map { |version| version_detail(version) }
    }
  end

  private

  def version_detail(version)
    json = {
      event: version.event,
      created_at: version.created_at,
      changes: version.changeset
    }
    user = User.find_by id: version.whodunnit
    if user
      json.merge(
        {
          user: {
            uuid: uuid,
            name: full_name,
            slug_name: slug_name
          }
        }
      )
    end
    json
  end
end
