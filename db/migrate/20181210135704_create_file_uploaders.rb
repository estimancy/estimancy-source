class CreateFileUploaders < ActiveRecord::Migration
  def change
    create_table :file_uploaders do |t|
      t.string :name
      t.string :attachment

      t.timestamps null: false
    end
  end
end
