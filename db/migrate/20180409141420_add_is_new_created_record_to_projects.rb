class AddIsNewCreatedRecordToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :is_new_created_record, :boolean
  end
end
