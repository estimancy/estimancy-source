class AddEndOfSeriesToViewsWidgets < ActiveRecord::Migration
  def change
    add_column :views_widgets, :end_of_series, :string

    add_column :kpis, :x_axis_config, :string
    add_column :kpis, :y_axis_config, :string
  end
end
