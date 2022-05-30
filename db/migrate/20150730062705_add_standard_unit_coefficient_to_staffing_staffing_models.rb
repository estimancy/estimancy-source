class AddStandardUnitCoefficientToStaffingStaffingModels < ActiveRecord::Migration
  def change
    add_column :staffing_staffing_models, :standard_unit_coefficient, :float
    add_column :staffing_staffing_models, :effort_unit, :string
  end
end
