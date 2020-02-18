class CreateWbsActivityRatioVariables < ActiveRecord::Migration
  def change

    create_table :wbs_activity_ratio_variables do |t|
      t.integer :wbs_activity_ratio_id
      t.string :name
      t.text :description
      t.string :percentage_of_input
      t.boolean :is_modifiable, default: false

      t.timestamps
    end


    create_table :module_project_ratio_variables do |t|
      t.integer :module_project_id
      t.integer :pbs_project_element_id
      t.integer :wbs_activity_ratio_id
      t.integer :wbs_activity_ratio_variable_id

      t.string :name
      t.text :description
      t.string :percentage_of_input
      t.float :value_from_percentage
      t.boolean :is_modifiable, default: false

      t.timestamps
    end
  end


end
