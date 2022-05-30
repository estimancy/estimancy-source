class AddEnableAjustedEffortToGuwTypes < ActiveRecord::Migration
  def change
    add_column :guw_guw_types, :disable_ajusted_effort, :boolean
  end
end
