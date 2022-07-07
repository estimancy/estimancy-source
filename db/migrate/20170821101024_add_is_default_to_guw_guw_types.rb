class AddIsDefaultToGuwGuwTypes < ActiveRecord::Migration
  def change
    add_column :guw_guw_types, :is_default, :boolean
  end
end
