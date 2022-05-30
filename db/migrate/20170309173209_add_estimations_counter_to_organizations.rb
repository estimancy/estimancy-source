class AddEstimationsCounterToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :estimations_counter, :integer
  end
end
