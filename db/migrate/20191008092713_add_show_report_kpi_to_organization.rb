class AddShowReportKpiToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :show_reports, :string
    add_column :organizations, :show_kpi, :string
  end
end
