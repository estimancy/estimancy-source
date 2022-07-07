class AddConfigTypeToGuwGuwModels < ActiveRecord::Migration
  def change
    add_column :guw_guw_models, :config_type, :string, default: "old"
  end
end
