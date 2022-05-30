class AddCalculationMethodToGeGeModel < ActiveRecord::Migration
  def change
    add_column :ge_ge_models, :p_calculation_method, :string
    add_column :ge_ge_models, :s_calculation_method, :string
    add_column :ge_ge_models, :c_calculation_method, :string
  end
end
