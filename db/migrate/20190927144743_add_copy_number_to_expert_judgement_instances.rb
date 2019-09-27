class AddCopyNumberToExpertJudgementInstances < ActiveRecord::Migration
  def change
    add_column :expert_judgement_instances, :copy_number, :integer, after: :copy_id
  end
end
