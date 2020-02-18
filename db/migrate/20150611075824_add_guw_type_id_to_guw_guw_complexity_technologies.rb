class AddGuwTypeIdToGuwGuwComplexityTechnologies < ActiveRecord::Migration
  def change
    add_column :guw_guw_complexity_technologies, :guw_type_id, :integer
  end
end
