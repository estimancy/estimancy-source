class Iwidget < ActiveRecord::Base

  belongs_to :indicator_dashboard
  #belongs_to :kpi

  belongs_to :serie_a_kpi, class_name: 'Kpi', foreign_key: :serie_a_kpi_id
  belongs_to :serie_b_kpi, class_name: 'Kpi', foreign_key: :serie_b_kpi_id
  belongs_to :serie_c_kpi, class_name: 'Kpi', foreign_key: :serie_c_kpi_id
  belongs_to :serie_d_kpi, class_name: 'Kpi', foreign_key: :serie_d_kpi_id

  validates :name, presence: true

  def self.output_types
    [[I18n.t(:minimum), "minimum"], [I18n.t(:maximum), "maximum"], [I18n.t(:average), "average"], [I18n.t(:median), "median"], [I18n.t(:sum), "sum"], [I18n.t(:counter), "counter"],
     [I18n.t(:first_value), "first_value"], [I18n.t(:last_value), "last_value"], [I18n.t(:table_values), "table_values"],
     [I18n.t(:line_chart), "line_chart"], [I18n.t(:bar_chart), "bar_chart"], [I18n.t(:stacked_bar_chart), "stacked_bar_chart"], [I18n.t(:pie_chart), "pie_chart"]]
  end


  def self.equation_output_types
    [[I18n.t(:minimum), "minimum"], [I18n.t(:maximum), "maximum"], [I18n.t(:average), "average"], [I18n.t(:median), "median"], [I18n.t(:sum), "sum"], [I18n.t(:counter), "counter"],
     [I18n.t(:first_value), "first_value"], [I18n.t(:last_value), "last_value"], [I18n.t(:table_values), "table_values"]]
  end

end
