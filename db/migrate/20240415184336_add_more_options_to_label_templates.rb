class AddMoreOptionsToLabelTemplates < ActiveRecord::Migration[6.0]
  def change
    add_column :gym_label_templates, :footer_options, :json, after: :layout_options
    add_column :gym_label_templates, :header_options, :json, after: :layout_options
    add_column :gym_label_templates, :label_options, :json, after: :layout_options
  end
end
