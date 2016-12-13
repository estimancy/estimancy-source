class AddModuleProjectIdToAttributesModules < ActiveRecord::Migration
  def change
    add_column :attribute_modules, :guw_model_id, :integer
  end
end
