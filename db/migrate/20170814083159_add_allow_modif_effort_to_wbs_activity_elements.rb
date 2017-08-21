class AddAllowModifEffortToWbsActivityElements < ActiveRecord::Migration
  def change
    add_column :wbs_activity_elements, :allow_modif_effort, :boolean
  end
end
