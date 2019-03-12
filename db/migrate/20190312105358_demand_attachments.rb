class DemandAttachments < ActiveRecord::Migration
  def change
    create_table :demand_attachments do |t|
      t.string :name
      t.string :attachment

      t.timestamps
    end
  end
end
