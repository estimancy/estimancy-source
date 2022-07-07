class AddStartDateToKpis < ActiveRecord::Migration
  def change
    add_column :kpis, :start_date, :date
    add_column :kpis, :end_date, :date
  end
end
