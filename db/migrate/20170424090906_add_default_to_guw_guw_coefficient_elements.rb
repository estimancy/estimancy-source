class AddDefaultToGuwGuwCoefficientElements < ActiveRecord::Migration
  def change
    begin
      add_column :guw_guw_coefficient_elements, :default, :boolean
    rescue
      #
    end
  end
end
