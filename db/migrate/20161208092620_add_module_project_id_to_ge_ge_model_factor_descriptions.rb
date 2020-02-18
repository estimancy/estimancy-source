class AddModuleProjectIdToGeGeModelFactorDescriptions < ActiveRecord::Migration
  def change
    add_column :ge_ge_model_factor_descriptions, :module_project_id, :integer
  end
end
