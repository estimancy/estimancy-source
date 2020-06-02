class AddActivateIndicatorsDashboardToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :activate_indicators_dashboard, :boolean
  end
end
