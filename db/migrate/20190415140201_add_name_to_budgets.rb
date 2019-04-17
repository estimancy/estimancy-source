class AddNameToBudgets < ActiveRecord::Migration
  def change
    # add_column :budgets, :name, :string
    begin
      add_column :budgets, :organization_id, :integer
    rescue
      # nothing to do
    end
  end
end
