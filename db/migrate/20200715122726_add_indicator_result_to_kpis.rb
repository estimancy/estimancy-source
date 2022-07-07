class AddIndicatorResultToKpis < ActiveRecord::Migration
  def change
    add_column :kpis, :period_start_date, :string
    add_column :kpis, :period_start_date_history, :integer

    add_column :kpis, :period_end_date, :string
    add_column :kpis, :period_end_date_history, :integer


    add_column :kpis, :indicator_result, :text
    remove_column :kpis, :kpi_type, :string
  end
end
