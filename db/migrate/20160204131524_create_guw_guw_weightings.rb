class CreateGuwGuwWeightings < ActiveRecord::Migration
  def change
    create_table :guw_guw_weightings do |t|
      t.integer :guw_model_id
      t.integer :copy_id
      t.string :name
      t.float :value
      t.integer :display_order

      t.timestamps
    end

    create_table :guw_guw_complexity_weightings do |t|
      t.integer :guw_complexity_id
      t.integer :guw_weighting_id
      t.float :value
      t.integer :guw_type_id

      t.timestamps
    end

    add_column :guw_guw_models, :weightings_label, :string
  end
end
