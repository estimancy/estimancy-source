class AddEffortDisplayUnitToViewsWidgets < ActiveRecord::Migration
  def change
    add_column :views_widgets, :effort_display_unit, :string
  end
end
