class AddCreatedAtToGeModels < ActiveRecord::Migration
  def up
    add_column(:ge_ge_models, :created_at, :datetime)
    add_column(:ge_ge_models, :updated_at, :datetime)

    Ge::GeModel.all.each do |i|
      i.save(validate: false)
      i.created_at = i.updated_at
      i.save(validate: false)
    end
  end

  def down
    remove_column :ge_ge_models, :created_at
    remove_column :ge_ge_models, :updated_at
  end
end
