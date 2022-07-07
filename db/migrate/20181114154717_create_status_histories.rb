class CreateStatusHistories < ActiveRecord::Migration
  def change
    create_table :status_histories do |t|
      t.string :organization
      t.string :project
      t.string :version_number
      t.datetime :change_date
      t.string :action
      t.text :comments
      t.string :origin
      t.string :target
      t.string :user

      t.timestamps
    end
  end
end
