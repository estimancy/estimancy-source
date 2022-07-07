class AddFields3ToGuwTypes < ActiveRecord::Migration
  def change
    add_column :guw_guw_types, :allow_quantity, :boolean
    add_column :guw_guw_types, :allow_retained, :boolean, default: true
    add_column :guw_guw_types, :allow_complexity, :boolean

    remove_column :guw_guw_types, :disable_ajusted_effort
  end
end
