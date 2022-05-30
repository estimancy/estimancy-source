class AddGuwUnitOfWorkIdToGuwGuwUnitOfWorks < ActiveRecord::Migration
  def change
    add_column :guw_guw_unit_of_works, :guw_unit_of_work_id, :integer
  end
end
