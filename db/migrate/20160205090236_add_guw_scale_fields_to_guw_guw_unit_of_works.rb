class AddGuwScaleFieldsToGuwGuwUnitOfWorks < ActiveRecord::Migration
  def change
    add_column :guw_guw_unit_of_works, :guw_weighting_id, :integer
    add_column :guw_guw_unit_of_works, :guw_factor_id, :integer
    add_column :guw_guw_unit_of_works, :size, :float
    add_column :guw_guw_unit_of_works, :cost, :float

    rename_column :guw_guw_unit_of_works, :ajusted_effort, :ajusted_size

  end
end
