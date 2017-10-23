class AddIndexUniqueNameToAllModules < ActiveRecord::Migration
  def change
    add_index :guw_guw_models, [:organization_id, :name], unique: true unless index_exists?(:guw_guw_models, [:organization_id, :name])

    add_index :wbs_activities, [:organization_id, :name], unique: true unless index_exists?(:wbs_activities, [:organization_id, :name])

    add_index :expert_judgement_instances, [:organization_id, :name], unique: true unless index_exists?(:expert_judgement_instances, [:organization_id, :name])

    add_index :operation_operation_models, [:organization_id, :name], unique: true unless index_exists?(:operation_operation_models, [:organization_id, :name])

    add_index :ge_ge_models, [:organization_id, :name], unique: true unless index_exists?(:ge_ge_models, [:organization_id, :name])

    add_index :kb_kb_models, [:organization_id, :name], unique: true unless index_exists?(:kb_kb_models, [:organization_id, :name])

    add_index :skb_skb_models, [:organization_id, :name], unique: true unless index_exists?(:skb_skb_models, [:organization_id, :name])

    add_index :staffing_staffing_models, [:organization_id, :name], unique: true unless index_exists?(:staffing_staffing_models, [:organization_id, :name])
  end
end
