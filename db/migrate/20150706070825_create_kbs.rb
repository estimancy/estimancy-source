class CreateKbs < ActiveRecord::Migration
  def up
    create_table :kb_kb_models do |t|
      t.string :name
      t.boolean :three_points_estimation
      t.boolean :enabled_input
      t.integer :organization_id
    end

    create_table :kb_kb_datas do |t|
      t.string :name
      t.float :size
      t.float :effort
      t.string :unit
      t.text :custom_attributes
      t.integer :kb_model_id
    end

    create_table :kb_kb_inputs do |t|
      t.string :formula
      t.text :values
      t.text :regression
      t.integer :organization_id
      t.integer :module_project_id
      t.integer :kb_model_id
    end

    add_column :module_projects, :kb_model_id, :integer
  end

  def down
    drop_table :kb_kb_datas
    drop_table :kb_kb_models
    drop_table :kb_kb_inputs
    remove_column :module_projects, :kb_model_id
  end
end
