class Iwidget < ActiveRecord::Base

  belongs_to :indicator_dashboard
  #belongs_to :kpi

  belongs_to :serie_a_kpi, class_name: 'Kpi', foreign_key: :serie_a_kpi_id
  belongs_to :serie_b_kpi, class_name: 'Kpi', foreign_key: :serie_b_kpi_id
  belongs_to :serie_c_kpi, class_name: 'Kpi', foreign_key: :serie_c_kpi_id
  belongs_to :serie_d_kpi, class_name: 'Kpi', foreign_key: :serie_d_kpi_id
end
