class AddCoefficientCalcToGuwGuwCoefficientElements < ActiveRecord::Migration
  def change
    begin
      add_column :guw_guw_coefficients, :coefficient_calc, :string
    rescue
      #
    end
  end
end
