class AddDefaultValueToGuwCoefficientElements < ActiveRecord::Migration
  def up
    add_column :guw_guw_coefficient_elements, :default_display_value, :float

    Guw::GuwCoefficientElement.all.each do |gce|
      gce.default_display_value = gce.value
      gce.save
    end
  end

  def down
    remove_column :guw_guw_coefficient_elements, :default_display_value
  end
end
