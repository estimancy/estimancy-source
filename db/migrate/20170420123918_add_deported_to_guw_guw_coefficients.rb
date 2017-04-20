class AddDeportedToGuwGuwCoefficients < ActiveRecord::Migration
  def change
    add_column :guw_guw_coefficients, :deported, :boolean, default: false
  end
end
