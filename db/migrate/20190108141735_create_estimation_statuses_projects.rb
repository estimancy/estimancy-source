class CreateEstimationStatusesProjects < ActiveRecord::Migration
  def change
    create_table :estimation_statuses_projects do |t|
      t.integer :estimation_status_id
      t.integer :project_id
      t.datetime :transition_date

      t.timestamps null: false
    end
  end

end
