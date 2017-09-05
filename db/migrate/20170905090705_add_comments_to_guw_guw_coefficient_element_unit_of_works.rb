class AddCommentsToGuwGuwCoefficientElementUnitOfWorks < ActiveRecord::Migration
  def change
    add_column :guw_guw_coefficient_element_unit_of_works, :comments, :text
  end
end
