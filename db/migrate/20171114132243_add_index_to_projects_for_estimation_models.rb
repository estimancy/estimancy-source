class AddIndexToProjectsForEstimationModels < ActiveRecord::Migration

  def up
    add_index :projects, [:organization_id, :is_model], name: :organization_estimation_models unless index_exists?(:projects, [:organization_id, :is_model], name: :organization_estimation_models)
  end


  def down
    remove_index :projects, name: :organization_estimation_models if index_exists?(:projects, [:organization_id, :is_model], name: :organization_estimation_models)
  end
end
