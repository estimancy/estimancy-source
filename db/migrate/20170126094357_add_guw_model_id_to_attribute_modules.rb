class AddGuwModelIdToAttributeModules < ActiveRecord::Migration
  def change
    add_column :pe_attributes, :guw_model_id, :integer
  end
end
