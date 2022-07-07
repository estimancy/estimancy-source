json.array!(@iwidgets) do |iwidget|
  json.extract! iwidget, :id, :indicator_dashboard_id, :name, :kpi_id, :indicator_output_id, :output_type, :serie_a_kpi_id, :serie_a_output, :serie_b_kpi_id, :serie_b_output, :serie_c_kpi_id, :serie_c_output, :serie_d_kpi_id, :serie_d_output, :icon_class, :color, :position_x, :position_y, :width, :height, :comment, :equation, :min_value, :max_value, :validation_text, :signalize
  json.url iwidget_url(iwidget, format: :json)
end
