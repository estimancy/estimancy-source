class AddActivateIndicatorsProjectDashboardOnOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :activate_project_dashboard_indicators, :boolean

    add_column :indicator_dashboards, :show_name_description, :boolean
    add_column :indicator_dashboards, :is_default_dashboard, :boolean

    change_column :kpis, :start_date, :datetime
    change_column :kpis, :end_date, :datetime

  end
end
