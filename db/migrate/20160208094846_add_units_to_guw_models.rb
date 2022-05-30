class AddUnitsToGuwModels < ActiveRecord::Migration
  def change
    add_column :guw_guw_models, :effort_unit, :string
    add_column :guw_guw_models, :cost_unit, :string
  end
end
