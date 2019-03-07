class AddAgreementIdToCriticalitySeverities < ActiveRecord::Migration
  def change
    add_column :criticality_severities, :agreement_id, :integer
  end
end
