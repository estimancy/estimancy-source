class AddFieldsToGuwGuwCoefficientElements < ActiveRecord::Migration
  def change
    add_column :guw_guw_coefficient_elements, :color_code, :string
    add_column :guw_guw_coefficient_elements, :color_priority, :integer
  end
end
