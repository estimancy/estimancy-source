class AddCreatedAtToKbModels < ActiveRecord::Migration
  def up
    add_column(:kb_kb_models, :created_at, :datetime)
    add_column(:kb_kb_models, :updated_at, :datetime)

    Kb::KbModel.all.each do |i|
      i.save(validate: false)
      i.created_at = i.updated_at
      i.save(validate: false)
    end
  end

  def down
    remove_column :kb_kb_models, :created_at
    remove_column :kb_kb_models, :updated_at
  end
end
