class AddDefaultToGeGeFactorValues < ActiveRecord::Migration
  def change
    add_column :ge_ge_factor_values, :default, :string, after: :value_number
  end
end
