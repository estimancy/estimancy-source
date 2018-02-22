class AddChangePrecisionToValueToGuwCoefficientElements < ActiveRecord::Migration
  def up
    change_column :guw_guw_coefficient_elements, :value, :decimal, :precision => 20, :scale => 10
  end

  def down
    change_column :guw_guw_coefficient_elements, :value, :float
  end
end
