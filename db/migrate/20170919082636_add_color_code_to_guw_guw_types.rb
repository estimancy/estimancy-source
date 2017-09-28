class AddColorCodeToGuwGuwTypes < ActiveRecord::Migration
  def change
    add_column :guw_guw_types, :color_code, :string
    add_column :guw_guw_types, :color_priority, :integer
  end
end
