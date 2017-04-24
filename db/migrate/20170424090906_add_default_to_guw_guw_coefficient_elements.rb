class AddDefaultToGuwGuwCoefficientElements < ActiveRecord::Migration
  def change
    add_column :guw_guw_coefficient_elements, :default, :boolean
  end
end
