class AddStaffingMethodToStaffingModels < ActiveRecord::Migration
  def change
    add_column :staffing_staffing_models, :staffing_method, :string
  end
end
