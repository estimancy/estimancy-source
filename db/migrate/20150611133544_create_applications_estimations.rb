class CreateApplicationsEstimations < ActiveRecord::Migration
  def change
    create_table :applications_projects, id: false do |t|
      t.integer :application_id
      t.integer :project_id
    end
  end
end
