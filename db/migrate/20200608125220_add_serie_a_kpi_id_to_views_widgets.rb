class AddSerieAKpiIdToViewsWidgets < ActiveRecord::Migration
  def change

    remove_column :views_widgets, :kpi_id

    add_column :views_widgets, :serie_a_kpi_id, :integer
    add_column :views_widgets, :serie_a_output_type, :string

    add_column :views_widgets, :serie_b_kpi_id, :integer
    add_column :views_widgets, :serie_b_output_type, :string

    add_column :views_widgets, :serie_c_kpi_id, :integer
    add_column :views_widgets, :serie_c_output_type, :string

    add_column :views_widgets, :serie_d_kpi_id, :integer
    add_column :views_widgets, :serie_d_output_type, :string

    add_column :views_widgets, :x_axis_label, :string
    add_column :views_widgets, :y_axis_label, :string

  end
end
