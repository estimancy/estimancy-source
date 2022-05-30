class CreateGuwGuwOutputApplications < ActiveRecord::Migration
  def change
    create_table :guw_guw_output_applications do |t|
      t.integer :organization_id
      t.integer :guw_model_id
      t.integer :guw_type_id
      t.integer :guw_output_id
      t.integer :application_id
      t.integer :guw_complexity_id

      t.float :value

      t.timestamps
    end
  end
end
