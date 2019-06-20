class ChangeStartDateToProjects < ActiveRecord::Migration
  def change
    change_column :projects, :start_date, :datetime
  end
end
