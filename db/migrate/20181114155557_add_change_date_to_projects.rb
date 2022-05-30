class AddChangeDateToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :change_date, :datetime
    add_column :projects, :time_count, :integer
  end
end
