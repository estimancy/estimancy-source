class AddIndexUniqueNameToAllModules < ActiveRecord::Migration
  def change
    add_index :guw_guw_models, [:organization_id, :name], unique: true
    add_index :wbs_activities, [:organization_id, :name], unique: true
    add_index :expert_judgement_instances, [:organization_id, :name], unique: true
    add_index :operation_operation_models, [:organization_id, :name], unique: true
    add_index :ge_ge_models, [:organization_id, :name], unique: true
    add_index :kb_kb_models, [:organization_id, :name], unique: true
    add_index :skb_skb_models, [:organization_id, :name], unique: true
    add_index :staffing_staffing_models, [:organization_id, :name], unique: true
  end
end
