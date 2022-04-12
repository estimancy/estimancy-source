class AddEnableFiltersToSkbSkbModels < ActiveRecord::Migration
  def change
    add_column :skb_skb_models, :enable_filters, :boolean, after: :enabled_input

    add_column :kb_kb_models, :description, :text
  end
end
