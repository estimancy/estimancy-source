class AddKpiUnitToViewsWidgets < ActiveRecord::Migration
  def change
    add_column :views_widgets, :kpi_unit, :string
  end
end
