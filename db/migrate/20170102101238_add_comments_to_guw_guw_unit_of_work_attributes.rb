class AddCommentsToGuwGuwUnitOfWorkAttributes < ActiveRecord::Migration
  def change
    add_column :guw_guw_unit_of_work_attributes, :comments, :text
  end
end
