class CreateIndexOnHistorizedEstimationModels < ActiveRecord::Migration
  def up
    add_index :projects, [:organization_id, :is_model, :is_historized], name: :organization_historized_estimation_models unless index_exists?(:projects, [:organization_id, :is_model, :is_historized], name: :organization_historized_estimation_models)
  end


  def down
    remove_index :projects, name: :organization_historized_estimation_models if index_exists?(:projects, [:organization_id, :is_model, :is_historized], name: :organization_historized_estimation_models)
  end
end
