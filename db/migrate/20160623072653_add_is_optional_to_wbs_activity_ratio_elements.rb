class AddIsOptionalToWbsActivityRatioElements < ActiveRecord::Migration
  def change
    add_column :wbs_activity_ratio_elements, :is_optional, :boolean

    add_column :module_project_ratio_elements, :is_optional, :boolean

    add_column :module_project_ratio_elements, :ancestry, :string
    add_index :module_project_ratio_elements, :ancestry

  end
end
