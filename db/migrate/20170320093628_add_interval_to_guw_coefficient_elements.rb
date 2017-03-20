class AddIntervalToGuwCoefficientElements < ActiveRecord::Migration
  def change
    add_column :guw_guw_coefficient_elements, :min_value, :float
    add_column :guw_guw_coefficient_elements, :max_value, :float
    add_column :guw_guw_coefficient_elements, :default_value, :float
  end
end
