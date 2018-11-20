class AddRangesToModels < ActiveRecord::Migration
  def change
    add_column :staffing_staffing_models, :min_range, :integer, default: 70
    add_column :staffing_staffing_models, :max_range, :integer, default: 150
  end
end