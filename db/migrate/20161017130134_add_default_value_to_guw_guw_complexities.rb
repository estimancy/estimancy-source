class AddDefaultValueToGuwGuwComplexities < ActiveRecord::Migration
  def change
    add_column :guw_guw_complexities, :default_value, :boolean
  end
end
