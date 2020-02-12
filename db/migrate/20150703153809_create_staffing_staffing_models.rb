class CreateStaffingStaffingModels < ActiveRecord::Migration
  def change
    create_table :staffing_staffing_models, :force => true  do |t|
      t.integer :organization_id
      t.string :name
      t.text :description
      t.float :mc_donell_coef
      t.float :puissance_n
      t.text  :trapeze_default_values    #serialized attribute
      t.boolean :three_points_estimation
      t.boolean :enabled_input
      t.integer :copy_id
      t.integer :copy_number

      t.timestamps
    end

    #Add staffing_model_id to ModuleProject
    add_column :module_projects, :staffing_model_id, :integer
  end
end
