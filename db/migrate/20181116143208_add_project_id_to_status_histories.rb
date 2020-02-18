class AddProjectIdToStatusHistories < ActiveRecord::Migration
  def change
    add_column :status_histories, :project_id, :integer, after: :organization
  end
end
