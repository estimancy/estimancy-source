class AddAllowManToGuwGuwModels < ActiveRecord::Migration
  def change
    add_column :guw_guw_models, :allow_man, :boolean
  end
end
