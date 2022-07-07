class AddIndexesToEstimationValues < ActiveRecord::Migration
  def change
    add_index :estimation_values, :module_project_id, name: "ev_mp_id"
    add_index :module_projects, :project_id, name: "mp_p_id"
  end
end
