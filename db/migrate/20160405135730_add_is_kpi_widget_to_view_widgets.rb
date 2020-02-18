class AddIsKpiWidgetToViewWidgets < ActiveRecord::Migration
  def change
    add_column :views_widgets, :is_kpi_widget, :boolean
  end
end
