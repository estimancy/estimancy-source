class AddChangedToGuwUnitOfWorks < ActiveRecord::Migration
  def change
    add_column :guw_guw_unit_of_works, :guw_original_complexity_id, :integer
  end
end
