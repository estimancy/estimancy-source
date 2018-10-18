class CreateBudgets < ActiveRecord::Migration
  def change
    create_table :budgets do |t|
      t.integer :organization_id
      t.integer :application_id
      t.integer :project_area_id
      t.integer :acquisition_category_id
      t.integer :platform_category_id
      t.integer :project_category_id
      t.integer :provider_id

      t.timestamps null: false
    end
  end
end
