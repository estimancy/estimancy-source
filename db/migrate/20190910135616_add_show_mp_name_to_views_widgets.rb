class AddShowMpNameToViewsWidgets < ActiveRecord::Migration
  def change
    add_column :views_widgets, :show_module_name, :boolean
  end
end
