class AddUnitToGuwGuwOutputs < ActiveRecord::Migration
  def change
    add_column :guw_guw_outputs, :unit, :string
  end
end
