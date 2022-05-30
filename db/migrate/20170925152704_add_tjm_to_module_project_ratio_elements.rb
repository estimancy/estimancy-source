class AddTjmToModuleProjectRatioElements < ActiveRecord::Migration
  def change
    add_column :module_project_ratio_elements, :tjm, :float, after: :ratio_value
  end
end
