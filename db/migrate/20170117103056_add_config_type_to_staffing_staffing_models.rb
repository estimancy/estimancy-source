class AddConfigTypeToStaffingStaffingModels < ActiveRecord::Migration
  def change
    add_column :staffing_staffing_models, :config_type, :string
  end
end
