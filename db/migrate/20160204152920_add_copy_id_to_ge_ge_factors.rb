class AddCopyIdToGeGeFactors < ActiveRecord::Migration
  def change
    add_column :ge_ge_factors, :copy_id, :integer
  end
end
