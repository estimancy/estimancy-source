class AddCopyNumberToInstanceModules < ActiveRecord::Migration
  def change
    add_column :guw_guw_models, :copy_number, :integer, default: 0
    add_column :ge_ge_models, :copy_number, :integer, default: 0
  end
end
