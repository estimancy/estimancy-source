class AddEquationToViewsWidgets < ActiveRecord::Migration
  def change
    add_column :views_widgets, :equation, :text
  end
end
