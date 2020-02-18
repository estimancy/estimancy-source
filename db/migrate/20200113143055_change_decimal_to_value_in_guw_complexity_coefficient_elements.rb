class ChangeDecimalToValueInGuwComplexityCoefficientElements < ActiveRecord::Migration
  def up
    change_column :guw_guw_complexity_coefficient_elements, :value, :decimal, :precision => 20, :scale => 3
  end

  def down
    change_column :guw_guw_complexity_coefficient_elements, :value, :float
  end
end
