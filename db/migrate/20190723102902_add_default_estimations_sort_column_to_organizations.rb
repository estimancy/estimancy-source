class AddDefaultEstimationsSortColumnToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :default_estimations_sort_column, :string
    add_column :organizations, :default_estimations_sort_order, :string
  end
end
