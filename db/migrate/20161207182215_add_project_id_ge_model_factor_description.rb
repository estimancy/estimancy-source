class AddProjectIdGeModelFactorDescription < ActiveRecord::Migration
  def change
    add_column :ge_ge_model_factor_descriptions, :project_id, :integer
  end
end
