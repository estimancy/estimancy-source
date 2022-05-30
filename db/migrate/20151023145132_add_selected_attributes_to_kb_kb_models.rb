class AddSelectedAttributesToKbKbModels < ActiveRecord::Migration
  def change
    add_column :kb_kb_models, :selected_attributes, :text
  end
end
