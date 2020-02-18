class AddRangesToModels < ActiveRecord::Migration
  def change
    add_column :staffing_staffing_models, :min_range, :integer
    add_column :staffing_staffing_models, :max_range, :integer
  end
end