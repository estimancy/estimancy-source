class CreateGuwOutputs < ActiveRecord::Migration
  def change
    create_table :guw_guw_outputs do |t|
      t.string :name
      t.string :output_type
      t.integer :guw_model_id

      t.timestamps
    end

    add_column :guw_guw_complexity_work_units, :guw_output_id, :integer
    add_column :guw_guw_complexity_factors, :guw_output_id, :integer
    add_column :guw_guw_complexity_weightings, :guw_output_id, :integer

    add_column :guw_guw_unit_of_works, :intermediate_work_unit_values, :float
    add_column :guw_guw_unit_of_works, :intermediate_weighting_values, :float
    add_column :guw_guw_unit_of_works, :intermediate_factor_values, :float

    change_column :guw_guw_unit_of_works, :ajusted_size, :text
    change_column :guw_guw_unit_of_works, :size, :text
    change_column :guw_guw_unit_of_works, :effort, :text
    change_column :guw_guw_unit_of_works, :cost, :text

    add_column :guw_guw_models, :work_unit_type, :string
    add_column :guw_guw_models, :weighting_type, :string
    add_column :guw_guw_models, :factor_type, :string

    add_column :guw_guw_models, :work_unit_min, :float
    add_column :guw_guw_models, :work_unit_max, :float

    add_column :guw_guw_models, :factor_min, :float
    add_column :guw_guw_models, :factor_max, :float

    add_column :guw_guw_models, :weighting_min, :float
    add_column :guw_guw_models, :weighting_max, :float

    add_column :guw_guw_unit_of_works, :work_unit_value, :float
    add_column :guw_guw_unit_of_works, :weighting_value, :float
    add_column :guw_guw_unit_of_works, :factor_value, :float
  end
end