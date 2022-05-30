class AddDescriptionToGuwGuwCoefficients < ActiveRecord::Migration
  def change
    begin
      add_column :guw_guw_coefficients, :description, :text
    rescue
      #
    end
  end
end
