class AddDescriptionToGuwGuwCoefficients < ActiveRecord::Migration
  def change
    add_column :guw_guw_coefficients, :description, :text
  end
end
