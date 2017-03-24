class ModifyGeModelsColumns < ActiveRecord::Migration
  def up

    add_column :ge_ge_models, :ge_model_instance_mode, :string, default: "standard"

    add_column :ge_ge_models, :ent1_is_modifiable, :boolean
    add_column :ge_ge_models, :ent2_is_modifiable, :boolean
    add_column :ge_ge_models, :ent3_is_modifiable, :boolean
    add_column :ge_ge_models, :ent4_is_modifiable, :boolean

    add_column :ge_ge_models, :sort1_is_modifiable, :boolean
    add_column :ge_ge_models, :sort2_is_modifiable, :boolean
    add_column :ge_ge_models, :sort3_is_modifiable, :boolean
    add_column :ge_ge_models, :sort4_is_modifiable, :boolean

    rename_column :ge_ge_models, :ent1_size_unit, :ent1_unit
    rename_column :ge_ge_models, :ent2_size_unit, :ent2_unit
    rename_column :ge_ge_models, :ent3_size_unit, :ent3_unit
    rename_column :ge_ge_models, :ent4_size_unit, :ent4_unit

    rename_column :ge_ge_models, :sort1_size_unit, :sort1_unit
    rename_column :ge_ge_models, :sort2_size_unit, :sort2_unit
    rename_column :ge_ge_models, :sort3_size_unit, :sort3_unit
    rename_column :ge_ge_models, :sort4_size_unit, :sort4_unit

    rename_column :ge_ge_models, :ent1_effort_unit_coefficient, :ent1_unit_coefficient
    rename_column :ge_ge_models, :ent2_effort_unit_coefficient, :ent2_unit_coefficient
    rename_column :ge_ge_models, :ent3_effort_unit_coefficient, :ent3_unit_coefficient
    rename_column :ge_ge_models, :ent4_effort_unit_coefficient, :ent4_unit_coefficient

    rename_column :ge_ge_models, :sort1_effort_unit_coefficient, :sort1_unit_coefficient
    rename_column :ge_ge_models, :sort2_effort_unit_coefficient, :sort2_unit_coefficient
    rename_column :ge_ge_models, :sort3_effort_unit_coefficient, :sort3_unit_coefficient
    rename_column :ge_ge_models, :sort4_effort_unit_coefficient, :sort4_unit_coefficient

    # delete column
    remove_column :ge_ge_models, :transform_size_and_effort, :display_size_and_effort_attributes
    remove_column :ge_ge_models, :ent1_effort_unit, :ent2_effort_unit, :ent3_effort_unit, :ent4_effort_unit
    remove_column :ge_ge_models, :sort1_effort_unit, :sort2_effort_unit, :sort3_effort_unit, :sort4_effort_unit
  end

  def down
    rename_column :ge_ge_models, :ent1_unit, :ent1_size_unit
    rename_column :ge_ge_models, :ent2_unit, :ent2_size_unit
    rename_column :ge_ge_models, :ent3_unit, :ent3_size_unit
    rename_column :ge_ge_models, :ent3_unit, :ent4_size_unit

    rename_column :ge_ge_models, :sort1_unit, :sort1_size_unit
    rename_column :ge_ge_models, :sort2_unit, :sort2_size_unit
    rename_column :ge_ge_models, :sort3_unit, :sort3_size_unit
    rename_column :ge_ge_models, :sort4_unit, :sort4_size_unit

    rename_column :ge_ge_models, :ent1_unit_coefficient, :ent1_effort_unit_coefficient
    rename_column :ge_ge_models, :ent2_unit_coefficient, :ent2_effort_unit_coefficient
    rename_column :ge_ge_models, :ent3_unit_coefficient, :ent3_effort_unit_coefficient
    rename_column :ge_ge_models, :ent4_unit_coefficient, :ent4_effort_unit_coefficient

    rename_column :ge_ge_models, :sort1_unit_coefficient, :sort1_effort_unit_coefficient
    rename_column :ge_ge_models, :sort2_unit_coefficient, :sort2_effort_unit_coefficient
    rename_column :ge_ge_models, :sort3_unit_coefficient, :sort3_effort_unit_coefficient
    rename_column :ge_ge_models, :sort4_unit_coefficient, :sort4_effort_unit_coefficient

    remove_column :ge_ge_models, :ge_model_instance_mode
    remove_column :ge_ge_models, :ent1_is_modifiable, :ent2_is_modifiable, :ent3_is_modifiable, :ent4_is_modifiable
    remove_column :ge_ge_models, :sort1_is_modifiable, :sort2_is_modifiable, :sort3_is_modifiable, :sort4_is_modifiable

    add_column :ge_ge_models, :transform_size_and_effort, :boolean
    add_column :ge_ge_models, :display_size_and_effort_attributes, :boolean

    add_column :ge_ge_models, :ent1_effort_unit, :string
    add_column :ge_ge_models, :ent2_effort_unit, :string
    add_column :ge_ge_models, :ent3_effort_unit, :string
    add_column :ge_ge_models, :ent4_effort_unit, :string

    add_column :ge_ge_models, :sort1_effort_unit, :string
    add_column :ge_ge_models, :sort2_effort_unit, :string
    add_column :ge_ge_models, :sort3_effort_unit, :string
    add_column :ge_ge_models, :sort4_effort_unit, :string

  end
end
