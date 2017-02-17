class AddStandardCoefficientToGuwGuwOutputs < ActiveRecord::Migration
  def change
    add_column :guw_guw_outputs, :standard_coefficient, :float
  end
end
