class ChangeScaleCoefficientComplexityValue < ActiveRecord::Migration
  def change
    change_column :guw_guw_complexity_coefficient_elements, :value, :decimal, :precision => 16, :scale => 6
  end
end
