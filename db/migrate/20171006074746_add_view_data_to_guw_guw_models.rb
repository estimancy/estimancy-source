class AddViewDataToGuwGuwModels < ActiveRecord::Migration
  def change
    add_column :guw_guw_models, :view_data, :boolean
  end
end
