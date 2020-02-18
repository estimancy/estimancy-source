class AddCopyNumberToKbKbModels < ActiveRecord::Migration
  def change
    add_column :kb_kb_models, :copy_number, :integer
  end
end
