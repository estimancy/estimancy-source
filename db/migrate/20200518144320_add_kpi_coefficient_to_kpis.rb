class AddKpiCoefficientToKpis < ActiveRecord::Migration
  def change
    add_column :kpis, :kpi_coefficient, :float
  end
end
