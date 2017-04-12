class CreateOperationOperationInputs < ActiveRecord::Migration
  def change
    create_table :operation_operation_inputs do |t|
      t.string :name
      t.text :description
      t.string  :in_out
      t.integer :operation_model_id
      t.boolean :is_modifiable
      t.float   :standard_unit_coefficient
      t.string  :standard_unit

      t.timestamps
    end

    add_column :operation_operation_models, :modify_output, :boolean
    rename_column :operation_operation_models, :effort_unit, :output_unit

    add_column :pe_attributes, :operation_model_id, :integer
    add_column :pe_attributes, :operation_input_id, :integer

    add_column :attribute_modules, :operation_model_id, :integer

  end
end
