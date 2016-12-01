class CreateGuwGuwComplexityGuwCoefficientElements < ActiveRecord::Migration
  def change
    create_table :guw_guw_complexity_coefficient_elements do |t|
      t.integer :guw_complexity_id
      t.integer :guw_coefficient_element_id
      t.integer :guw_output_id
      t.integer :guw_type_id
      t.float :value
      t.timestamps
    end
  end
end
