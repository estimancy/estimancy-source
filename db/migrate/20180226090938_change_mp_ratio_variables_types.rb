class ChangeMpRatioVariablesTypes < ActiveRecord::Migration
  def up
    change_column :module_project_ratio_variables, :value_from_percentage, :decimal, :precision => 25, :scale => 10
  end

  def down
    change_column :module_project_ratio_variables, :value_from_percentage, :decimal, :precision => 20, :scale => 6
  end
end
