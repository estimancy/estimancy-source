class AddValueBToGuwGuwAttributeComplexities < ActiveRecord::Migration
  def change
    add_column :guw_guw_attribute_complexities, :value_b, :float
  end
end
