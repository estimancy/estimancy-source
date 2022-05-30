class AddQuantityToGuwGuwUnitOfWorks < ActiveRecord::Migration
  def change
    add_column :guw_guw_unit_of_works, :quantity, :float
  end
end
