class ModifyBudgets < ActiveRecord::Migration
  def change
    remove_column :budgets, :project_area_id
    remove_column :budgets, :acquisition_category_id
    remove_column :budgets, :platform_category_id
    remove_column :budgets, :project_category_id
    remove_column :budgets, :provider_id
    add_column :budgets, :start_date, :datetime
    add_column :budgets, :end_date, :datetime
    add_column :budgets, :sum, :integer
  end
end
