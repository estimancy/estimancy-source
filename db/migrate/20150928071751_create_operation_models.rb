class CreateOperationModels < ActiveRecord::Migration
  def change
    create_table :operation_operation_models do |t|
      t.string :name
      t.boolean :three_points_estimation
      t.boolean :enabled_input
      t.integer :organization_id
      t.string :effort_unit
      t.integer :standard_unit_coefficient
      t.string :operation_type
      t.integer :copy_id
      t.integer :copy_number
    end

    add_column :module_projects, :operation_model_id, :integer
  end
end
