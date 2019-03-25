class CreateFileUploaders < ActiveRecord::Migration
  def change
    begin
      create_table :file_uploaders do |t|
        t.string :name
        t.text :attachment

        t.timestamps null: false
      end
    rescue
    end
  end
end
