class AddCopyIdToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :copy_id, :integer
  end
end
