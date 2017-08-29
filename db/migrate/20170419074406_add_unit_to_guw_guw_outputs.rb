class AddUnitToGuwGuwOutputs < ActiveRecord::Migration
  def change
    begin
      add_column :guw_guw_outputs, :unit, :string
    rescue
      #
    end
  end
end
