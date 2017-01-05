class CreateGuwGuwOutputAssociations < ActiveRecord::Migration
  def change
    create_table :guw_guw_output_associations do |t|
      t.integer :guw_output_id
      t.integer :guw_output_associated_id
      t.integer :guw_complexity_id
      t.float :value

      t.timestamps
    end
  end
end
