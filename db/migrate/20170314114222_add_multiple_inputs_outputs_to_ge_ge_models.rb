class AddMultipleInputsOutputsToGeGeModels < ActiveRecord::Migration
  def change
    # Entrees
    add_column :ge_ge_models, :ent1_size_unit, :string
    add_column :ge_ge_models, :ent1_effort_unit, :string
    add_column :ge_ge_models, :ent1_effort_unit_coefficient, :float, default: 1

    add_column :ge_ge_models, :ent2_size_unit, :string
    add_column :ge_ge_models, :ent2_effort_unit, :string
    add_column :ge_ge_models, :ent2_effort_unit_coefficient, :float, default: 1

    add_column :ge_ge_models, :ent3_size_unit, :string
    add_column :ge_ge_models, :ent3_effort_unit, :string
    add_column :ge_ge_models, :ent3_effort_unit_coefficient, :float, default: 1

    add_column :ge_ge_models, :ent4_size_unit, :string
    add_column :ge_ge_models, :ent4_effort_unit, :string
    add_column :ge_ge_models, :ent4_effort_unit_coefficient, :float, default: 1

    # Sorties
    add_column :ge_ge_models, :sort1_size_unit, :string
    add_column :ge_ge_models, :sort1_effort_unit, :string
    add_column :ge_ge_models, :sort1_effort_unit_coefficient, :float, default: 1

    add_column :ge_ge_models, :sort2_size_unit, :string
    add_column :ge_ge_models, :sort2_effort_unit, :string
    add_column :ge_ge_models, :sort2_effort_unit_coefficient, :float, default: 1

    add_column :ge_ge_models, :sort3_size_unit, :string
    add_column :ge_ge_models, :sort3_effort_unit, :string
    add_column :ge_ge_models, :sort3_effort_unit_coefficient, :float, default: 1

    add_column :ge_ge_models, :sort4_size_unit, :string
    add_column :ge_ge_models, :sort4_effort_unit, :string
    add_column :ge_ge_models, :sort4_effort_unit_coefficient, :float, default: 1

  end
end
