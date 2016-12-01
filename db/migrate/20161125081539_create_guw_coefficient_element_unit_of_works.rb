class CreateGuwCoefficientElementUnitOfWorks < ActiveRecord::Migration
  def change
    create_table :guw_guw_coefficient_element_unit_of_works do |t|
      t.integer :guw_unit_of_work_id
      t.integer :guw_coefficient_element_id
      t.integer :guw_coefficient_id
      t.float :percent
      t.float :intermediate_value
      t.timestamps
    end
  end
end
