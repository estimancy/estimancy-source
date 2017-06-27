class AddAllowMlToGuwGuwModels < ActiveRecord::Migration
  def change
    add_column :guw_guw_models, :allow_ml, :boolean
  end
end
