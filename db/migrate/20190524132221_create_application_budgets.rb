class CreateApplicationBudgets < ActiveRecord::Migration
  def up
    # create_table :application_budgets do |t|
    #   t.integer :organization_id
    #   t.integer :budget_id
    #   t.integer :application_id
    #   t.float :montant
    #   t.boolean :is_used
    #
    #   t.timestamps null: false
    # end
  end

  def down
    drop_table :application_budgets
  end
end
