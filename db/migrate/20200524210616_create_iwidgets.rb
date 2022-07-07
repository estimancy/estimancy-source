class CreateIwidgets < ActiveRecord::Migration
  def change
    create_table :iwidgets do |t|
      t.integer :indicator_dashboard_id
      t.string :name

      t.integer :serie_a_kpi_id
      t.string  :serie_a_output_type

      t.integer :serie_b_kpi_id
      t.string  :serie_b_output_type

      t.integer :serie_c_kpi_id
      t.string  :serie_c_output_type

      t.integer :serie_d_kpi_id
      t.string  :serie_d_output_type

      t.string :icon_class
      t.string :color
      t.string :position_x
      t.string :position_y
      t.string :width
      t.string :height
      t.boolean :is_label_widget
      t.text :comment
      t.boolean :is_calculation_widget
      t.text :equation
      t.integer :min_value
      t.integer :max_value
      t.string :validation_text
      t.boolean :signalize
      t.string :x_axis_label
      t.string :y_axis_label

      t.timestamps null: false
    end
  end
end
