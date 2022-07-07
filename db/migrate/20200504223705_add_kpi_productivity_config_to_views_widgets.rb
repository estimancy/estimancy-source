class AddKpiProductivityConfigToViewsWidgets < ActiveRecord::Migration
  def up
    add_column :views_widgets, :is_organization_kpi_widget, :boolean
    add_column :views_widgets, :kpi_id, :integer
    add_column :views_widgets, :signalize, :boolean
    add_column :views_widgets, :lock_project, :boolean


    ViewsWidget.all.each do |view_widget|
      borne_min = view_widget.min_value
      borne_max = view_widget.max_value

      unless borne_min.nil? || borne_max.nil?
        view_widget.signalize = true
        view_widget.lock_project = true
        view_widget.save
      end
    end
  end

  def down
    remove_column :views_widgets, :is_organization_kpi_widget
    remove_column :views_widgets, :kpi_id
    remove_column :views_widgets, :signalize
    remove_column :views_widgets, :lock_project
  end
end
