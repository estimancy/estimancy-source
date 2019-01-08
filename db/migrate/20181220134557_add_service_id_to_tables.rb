class AddServiceIdToTables < ActiveRecord::Migration
  def change
=begin
    add_column :wbs_activity_elements, :service_id, :integer
    add_column :guw_guw_types, :service_id, :integer
=end
  end
end
