class AddMissingValueToGuwUnitOfWorks < ActiveRecord::Migration
  def change
    add_column :guw_guw_unit_of_works, :missing_value, :boolean, default: false
  end
end
