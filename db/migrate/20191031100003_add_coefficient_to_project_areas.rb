class AddCoefficientToProjectAreas < ActiveRecord::Migration
  def change
    add_column :project_areas, :coefficient, :float
    add_column :project_areas, :coefficient_label, :string

    add_column :project_categories, :coefficient, :float
    add_column :project_categories, :coefficient_label, :string

    add_column :platform_categories, :coefficient, :float
    add_column :platform_categories, :coefficient_label, :string

    add_column :acquisition_categories, :coefficient, :float
    add_column :acquisition_categories, :coefficient_label, :string

    add_column :providers, :coefficient, :float
    add_column :providers, :coefficient_label, :string
  end
end
