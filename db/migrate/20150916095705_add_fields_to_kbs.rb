class AddFieldsToKbs < ActiveRecord::Migration
  def change
    add_column :kb_kb_models, :standard_unit_coefficient, :float
    add_column :kb_kb_models, :effort_unit, :string
  end
end
