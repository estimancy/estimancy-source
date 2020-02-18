class ChangePrecisionToWeightInGuwComplexities < ActiveRecord::Migration
  def up
    change_column :guw_guw_complexities, :weight, :decimal, :precision => 20, :scale => 7
  end

  def down
    change_column :guw_guw_complexities, :weight, :float
  end
end
