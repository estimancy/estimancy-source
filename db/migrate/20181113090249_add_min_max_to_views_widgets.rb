class AddMinMaxToViewsWidgets < ActiveRecord::Migration
  def change
    add_column :views_widgets, :min_value, :int
    add_column :views_widgets, :max_value, :int
  end
end
