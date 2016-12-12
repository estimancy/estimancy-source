class CreateGeModelFactorDescriptions < ActiveRecord::Migration

  def change
    create_table :ge_ge_model_factor_descriptions do |t|

      t.integer :ge_model_id
      t.integer :ge_factor_id
      t.string :factor_alias
      t.text :description
      t.integer :organization_id

    end
  end

end
