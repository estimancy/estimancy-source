class AddOriginTargetModeToAgreements < ActiveRecord::Migration
  def change
    add_column :agreements, :origin_target_mode, :string
  end
end
