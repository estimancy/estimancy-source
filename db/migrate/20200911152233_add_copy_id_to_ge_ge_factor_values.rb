class AddCopyIdToGeGeFactorValues < ActiveRecord::Migration
  def change
    add_column :ge_ge_factor_values, :copy_id, :integer
  end
end
