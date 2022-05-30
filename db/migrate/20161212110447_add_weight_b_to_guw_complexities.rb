class AddWeightBToGuwComplexities < ActiveRecord::Migration
  def change
    add_column :guw_guw_complexities, :weight_b, :float
  end
end
