class AddDeportedToGuwGuwCoefficients < ActiveRecord::Migration
  def change
    begin
      add_column :guw_guw_coefficients, :deported, :boolean, default: false
    rescue
      #
    end
  end
end
