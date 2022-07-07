class AddAdditionalDescriptionToGuwGuwAttributeTypes < ActiveRecord::Migration
  def change
    add_column :guw_guw_attribute_types, :additional_description, :text
  end
end
