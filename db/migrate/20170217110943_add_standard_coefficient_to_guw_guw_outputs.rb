class AddStandardCoefficientToGuwGuwOutputs < ActiveRecord::Migration
  def change
    begin
      add_column :guw_guw_outputs, :standard_coefficient, :float
    rescue
      #
    end
  end
end
