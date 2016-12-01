class CreateGuwCoefficients < ActiveRecord::Migration
  def change
    create_table :guw_guw_coefficients do |t|
      t.string :name
      t.string :coefficient_type

      t.integer :guw_model_id

      t.timestamps
    end

    create_table :guw_guw_coefficient_elements do |t|
      t.string :name
      t.integer :guw_coefficient_id
      t.float :value
      t.integer :display_order

      t.integer :guw_model_id

      t.timestamps
    end

    create_table :guw_guw_coefficient_elements_outputs do |t|
      t.integer :guw_coefficient_id
      t.integer :guw_guw_coefficient_element_id

      t.timestamps
    end

    add_column :guw_guw_scale_module_attributes, :guw_output_id, :integer
    add_column :guw_guw_scale_module_attributes, :guw_coefficient_id, :integer

  end
end
