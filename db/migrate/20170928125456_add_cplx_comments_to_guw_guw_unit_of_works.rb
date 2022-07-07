class AddCplxCommentsToGuwGuwUnitOfWorks < ActiveRecord::Migration
  def change
    add_column :guw_guw_unit_of_works, :cplx_comments, :text
  end
end
