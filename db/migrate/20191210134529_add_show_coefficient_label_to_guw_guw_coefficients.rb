class AddShowCoefficientLabelToGuwGuwCoefficients < ActiveRecord::Migration
  def change
    add_column :guw_guw_coefficients, :show_coefficient_label, :boolean
  end
end
