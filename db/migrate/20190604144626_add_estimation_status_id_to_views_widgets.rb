class AddEstimationStatusIdToViewsWidgets < ActiveRecord::Migration
  def change
    add_column :views_widgets, :estimation_status_id, :integer
  end
end
