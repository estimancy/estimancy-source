class AddFieldsToGuwGuwTypes < ActiveRecord::Migration
  def change
    add_column :guw_guw_types, :maximum, :integer
  end
end
