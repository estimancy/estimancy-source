class CreateGuwGuwFactors < ActiveRecord::Migration
  def change
    create_table :guw_guw_factors do |t|
      t.integer :guw_model_id
      t.integer :copy_id
      t.string :name
      t.float :value
      t.integer :display_order

      t.timestamps
    end

    create_table :guw_guw_complexity_factors do |t|
      t.integer :guw_complexity_id
      t.integer :guw_factor_id
      t.float :value
      t.integer :guw_type_id

      t.timestamps
    end

    add_column :guw_guw_models, :factors_label, :string
  end
end
