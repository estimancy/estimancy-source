class AddCoefficientCalcToGuwGuwCoefficientElements < ActiveRecord::Migration
  def change
    add_column :guw_guw_coefficients, :coefficient_calc, :string
  end
end
