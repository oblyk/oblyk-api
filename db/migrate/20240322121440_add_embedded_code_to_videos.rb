class AddEmbeddedCodeToVideos < ActiveRecord::Migration[6.0]
  def change
    add_column :videos, :embedded_code, :text, after: :url
    add_column :videos, :video_service, :string, after: :description
  end
end
