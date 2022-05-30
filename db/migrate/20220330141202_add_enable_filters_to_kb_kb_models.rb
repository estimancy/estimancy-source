class AddEnableFiltersToKbKbModels < ActiveRecord::Migration
  def change
    add_column :kb_kb_models, :enable_filters, :boolean, after: :enabled_input
    add_column :kb_kb_datas, :description, :text
  end
end
