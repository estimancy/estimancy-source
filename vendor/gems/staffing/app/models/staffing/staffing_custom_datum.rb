module Staffing
  class StaffingCustomDatum < ActiveRecord::Base
    attr_accessible :staffing_model_id, :module_project_id, :pbs_project_element_id, :mc_donell_coef, :puissance_n,
                    :coef_a, :coef_a_prime, :coef_b, :coef_b_prime, :duration, :rayleigh_duration, :max_staffing,
                    :staffing_constraint, :actuals_based_on,
                    :global_effort_value, :trapeze_default_values, :trapeze_parameter_values, :max_staffing_rayleigh

    serialize :trapeze_default_values, Hash
    serialize :trapeze_parameter_values, Hash

    serialize :trapeze_chart_theoretical_coordinates, Array
    serialize :rayleigh_chart_theoretical_coordinates, Array
    serialize :chart_actual_coordinates, Array
    serialize :mcdonnell_chart_theorical_coordinates, Array


    belongs_to :staffing_model
    belongs_to :module_project
    belongs_to :pbs_project_element

  end
end
