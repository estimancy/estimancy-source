class AddIsProjectDataWidgetToViewsWidgets < ActiveRecord::Migration
  def change
    add_column :views_widgets, :is_project_data_widget, :boolean
    add_column :views_widgets, :project_attribute_name, :string
  end
end
