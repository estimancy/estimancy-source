class AddDescriptionToGuwGuwCoefficientElements < ActiveRecord::Migration
  def change
    begin
      add_column :guw_guw_coefficient_elements, :description, :text
    rescue
      #
    end
  end
end
