class ChangeColumnEffortDisplayUnitToViewsWidgets < ActiveRecord::Migration

  def change
    remove_column :views_widgets, :effort_display_unit
    add_column :views_widgets, :use_organization_effort_unit, :boolean
  end
end
