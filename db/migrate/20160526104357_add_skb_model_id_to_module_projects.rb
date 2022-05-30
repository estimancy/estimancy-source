class AddSkbModelIdToModuleProjects < ActiveRecord::Migration
  def change
    add_column :module_projects, :skb_model_id, :integer
  end
end
