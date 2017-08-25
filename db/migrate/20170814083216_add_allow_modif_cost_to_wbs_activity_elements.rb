class AddAllowModifCostToWbsActivityElements < ActiveRecord::Migration
  def change
    add_column :wbs_activity_elements, :allow_modif_cost, :boolean
  end
end
