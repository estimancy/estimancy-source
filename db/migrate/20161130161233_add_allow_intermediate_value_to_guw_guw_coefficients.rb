class AddAllowIntermediateValueToGuwGuwCoefficients < ActiveRecord::Migration
  def change
    add_column :guw_guw_coefficients, :allow_intermediate_value, :boolean
    add_column :guw_guw_outputs, :allow_intermediate_value, :boolean
  end
end
