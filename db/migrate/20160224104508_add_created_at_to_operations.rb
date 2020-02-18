class AddCreatedAtToOperations < ActiveRecord::Migration
  def up
    add_column(:operation_operation_models, :created_at, :datetime)
    add_column(:operation_operation_models, :updated_at, :datetime)

    Operation::OperationModel.all.each do |i|
      i.save(validate: false)
      i.created_at = i.updated_at
      i.save(validate: false)
    end
  end

  def down
    remove_column :operation_operation_models, :created_at
    remove_column :operation_operation_models, :updated_at
  end
end
