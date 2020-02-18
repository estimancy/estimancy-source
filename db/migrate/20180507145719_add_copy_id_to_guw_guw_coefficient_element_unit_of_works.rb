class AddCopyIdToGuwGuwCoefficientElementUnitOfWorks < ActiveRecord::Migration
  def change
    add_column :guw_guw_coefficient_element_unit_of_works, :copy_id, :integer
  end
end
