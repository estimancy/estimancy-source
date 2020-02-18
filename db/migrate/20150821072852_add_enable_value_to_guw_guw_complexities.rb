class AddEnableValueToGuwGuwComplexities < ActiveRecord::Migration
  def change
    add_column :guw_guw_complexities, :enable_value, :boolean
  end
end
