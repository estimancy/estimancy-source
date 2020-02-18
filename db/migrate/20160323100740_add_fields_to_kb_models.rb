class AddFieldsToKbModels < ActiveRecord::Migration
  def change
    add_column :kb_kb_models, :n_max, :integer
    add_column :kb_kb_models, :date_max, :date
    add_column :kb_kb_models, :date_min, :date
    add_column :kb_kb_models, :filter_a, :string
    add_column :kb_kb_models, :filter_b, :string
    add_column :kb_kb_models, :filter_c, :string
    add_column :kb_kb_models, :filter_d, :string
  end
end
