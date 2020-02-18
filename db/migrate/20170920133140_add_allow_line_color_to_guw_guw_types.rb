class AddAllowLineColorToGuwGuwTypes < ActiveRecord::Migration
  def change
    add_column :guw_guw_types, :allow_line_color, :boolean
  end
end
