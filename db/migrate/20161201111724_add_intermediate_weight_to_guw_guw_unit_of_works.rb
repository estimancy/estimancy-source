class AddIntermediateWeightToGuwGuwUnitOfWorks < ActiveRecord::Migration
  def change
    add_column :guw_guw_unit_of_works, :intermediate_weight, :float
    add_column :guw_guw_unit_of_works, :intermediate_percent, :float
    add_column :guw_guw_types, :display_threshold, :boolean
  end
end
