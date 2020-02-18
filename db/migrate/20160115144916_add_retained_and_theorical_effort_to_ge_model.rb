class AddRetainedAndTheoricalEffortToGeModel < ActiveRecord::Migration
  def change
    add_column :ge_ge_models, :modify_theorical_effort, :boolean, after: :enabled_input
    add_column :ge_ge_models, :description, :text, after: :name
  end
end
