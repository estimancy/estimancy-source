class AddOrdersToGuwGuwModels < ActiveRecord::Migration
  def change
    add_column :guw_guw_models, :orders, :text
  end
end
