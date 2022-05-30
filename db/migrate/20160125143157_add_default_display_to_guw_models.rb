class AddDefaultDisplayToGuwModels < ActiveRecord::Migration
  def change
    add_column :guw_guw_models, :default_display, :string
  end
end
