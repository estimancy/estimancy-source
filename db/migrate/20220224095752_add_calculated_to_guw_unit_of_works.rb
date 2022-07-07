class AddCalculatedToGuwUnitOfWorks < ActiveRecord::Migration

  def change
    add_column :guw_guw_unit_of_works, :calculated, :boolean

    add_column :module_projects, :number_uncalculated_uows, :integer
  end

end
