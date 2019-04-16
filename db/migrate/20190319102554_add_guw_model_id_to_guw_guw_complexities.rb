class AddGuwModelIdToGuwGuwComplexities < ActiveRecord::Migration
  def change
    add_column :guw_guw_complexities, :guw_model_id, :integer
  end
end
