class AddAttributeTypeToGuwGuwTypes < ActiveRecord::Migration
  def change
    add_column :guw_guw_types, :attribute_type, :string
  end
end
