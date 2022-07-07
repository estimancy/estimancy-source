class AddCopyIdToKbKbModels < ActiveRecord::Migration
  def change
    add_column :kb_kb_models, :copy_id, :integer
  end
end
