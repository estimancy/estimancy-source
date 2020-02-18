class AddEnableValueToGuwAttributeComplexities < ActiveRecord::Migration
  def change
    add_column :guw_guw_attribute_complexities, :enable_value, :boolean
  end
end
