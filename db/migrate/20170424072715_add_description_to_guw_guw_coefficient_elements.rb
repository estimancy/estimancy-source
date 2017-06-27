class AddDescriptionToGuwGuwCoefficientElements < ActiveRecord::Migration
  def change
    add_column :guw_guw_coefficient_elements, :description, :text
  end
end
