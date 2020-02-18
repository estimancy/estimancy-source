class CreateGuwGuwAttributesTypes < ActiveRecord::Migration
  def change
    begin
      create_table :guw_guw_attribute_types do |t|
        t.integer :guw_type_id
        t.integer :guw_attribute_id
        t.float :default_value
        t.timestamps
      end
    rescue
      #
    end
  end
end
