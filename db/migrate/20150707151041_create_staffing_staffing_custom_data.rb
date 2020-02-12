class CreateStaffingStaffingCustomData < ActiveRecord::Migration
  def change
    create_table :staffing_staffing_custom_data do |t|
      t.integer :staffing_model_id
      t.integer :module_project_id
      t.integer :pbs_project_element_id

      t.string :staffing_method
      t.string :period_unit
      t.string :global_effort_type   #min, max or probable
      t.float  :global_effort_value
      t.string :staffing_constraint
      t.float :duration
      t.float :max_staffing
      t.float :t_max_staffing
      t.float :mc_donell_coef
      t.float :puissance_n
      t.text  :trapeze_default_values     #serialized attribute
      t.text  :trapeze_parameter_values   #serialized attribute
      t.float :form_coef
      t.float :difficulty_coef
      t.float :coef_a
      t.float :coef_b
      t.float :coef_a_prime
      t.float :coef_b_prime
      t.float :calculated_effort
      t.float :theoretical_staffing
      t.float :calculated_staffing
      t.text  :chart_theoretical_coordinates
      t.text  :chart_actual_coordinates

      t.integer :copy_id
      t.integer :copy_number

      t.timestamps
    end
  end
end
