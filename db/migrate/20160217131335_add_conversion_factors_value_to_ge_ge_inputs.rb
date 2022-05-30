class AddConversionFactorsValueToGeGeInputs < ActiveRecord::Migration
  def change
    rename_column :ge_ge_inputs, :scale_factor_sum, :s_factors_value
    rename_column :ge_ge_inputs, :prod_factor_product, :p_factors_value

    add_column :ge_ge_inputs, :c_factors_value, :float, after: :p_factors_value
  end
end
