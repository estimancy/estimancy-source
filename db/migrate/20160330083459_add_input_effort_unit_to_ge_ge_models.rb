class AddInputEffortUnitToGeGeModels < ActiveRecord::Migration
  def up
    change_column :ge_ge_models, :size_unit, :string, after: :organization_id

    rename_column :ge_ge_models, :size_unit, :input_size_unit
    rename_column :ge_ge_models, :effort_unit, :output_effort_unit
    rename_column :ge_ge_models, :standard_unit_coefficient, :output_effort_standard_unit_coefficient

    add_column :ge_ge_models, :output_size_unit, :string,  after: :input_size_unit
    add_column :ge_ge_models, :input_effort_unit, :string,  after: :output_size_unit
    add_column :ge_ge_models, :input_effort_standard_unit_coefficient, :float,  after: :output_effort_standard_unit_coefficient


    # copy all old data in new created attributes
    Ge::GeModel.all.each do |ge_model|
      ge_model.output_size_unit = ge_model.input_size_unit
      ge_model.input_effort_unit = ge_model.output_effort_unit
      ge_model.input_effort_standard_unit_coefficient = ge_model.output_effort_standard_unit_coefficient
      ge_model.save(validate: false)
    end

  end


  def down
    remove_column :ge_ge_models, :output_size_unit
    remove_column :ge_ge_models, :input_effort_unit
    remove_column :ge_ge_models, :input_effort_standard_unit_coefficient

    rename_column :ge_ge_models, :input_size_unit, :size_unit
    rename_column :ge_ge_models, :output_effort_unit, :effort_unit
    rename_column :ge_ge_models, :output_effort_standard_unit_coefficient, :standard_unit_coefficient
  end

end
