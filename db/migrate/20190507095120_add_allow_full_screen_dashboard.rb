class AddAllowFullScreenDashboard < ActiveRecord::Migration
  def change
    add_column :users, :allow_full_screen_dashboard, :bool
  end
end
