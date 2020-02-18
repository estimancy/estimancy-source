class AddBusinessNeedToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :business_need, :string
  end
end
