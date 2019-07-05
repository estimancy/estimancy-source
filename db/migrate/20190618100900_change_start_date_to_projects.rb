class ChangeStartDateToProjects < ActiveRecord::Migration
  def up
    change_column :projects, :start_date, :datetime
  end

  def down
    change_column :projects, :start_date, :date
  end
end
