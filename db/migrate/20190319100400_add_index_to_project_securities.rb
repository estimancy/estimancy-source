class AddIndexToProjectSecurities < ActiveRecord::Migration
  def change
    add_index :project_securities, [:group_id, :is_model_permission, :is_estimation_permission], name: :ability_project_securities
    # add_index :permissions, :project_security_level_id, name: :ability_permissions
  end
end
