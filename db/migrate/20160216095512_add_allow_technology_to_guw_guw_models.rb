class AddAllowTechnologyToGuwGuwModels < ActiveRecord::Migration
  def change
    add_column :guw_guw_models, :allow_technology, :boolean, default: true
  end
end
