class CreateScaleModuleAttributesTable < ActiveRecord::Migration
  def change
    create_table :guw_guw_scale_module_attributes do |t|
      t.integer :guw_model_id
      t.string :type_attribute
      t.string :type_scale

      t.timestamps
    end
  end
end
