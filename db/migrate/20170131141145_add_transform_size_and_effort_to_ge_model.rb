class AddTransformSizeAndEffortToGeModel < ActiveRecord::Migration
  def change
    add_column :ge_ge_models, :transform_size_and_effort, :boolean
    add_column :ge_ge_models, :display_size_and_effort_attributes, :boolean
  end
end
