class CreateGymLabelTemplates < ActiveRecord::Migration[6.0]
  def change
    create_table :gym_label_templates do |t|
      t.string :name
      t.string :label_direction # side_by_side, stacked, circular, etc.
      t.json :layout_options # example : radius for circular label
      t.json :border_style # color, width, dash, etc.
      t.string :font_family
      t.string :qr_code_position # footer, in label, none
      t.string :label_arrangement # what label looks like
      t.string :grade_style # what the grade looks like

      # Display options
      t.boolean :display_points
      t.boolean :display_openers
      t.boolean :display_opened_at
      t.boolean :display_name
      t.boolean :display_description
      t.boolean :display_anchor
      t.boolean :display_climbing_style

      t.string :page_format # A4, A5, etc.
      t.string :page_direction # portrait or landscape
      t.references :gym, foreign_key: true
      t.datetime :archived_at
      t.timestamps
    end
  end
end
