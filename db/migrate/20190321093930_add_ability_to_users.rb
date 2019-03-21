class AddAbilityToUsers < ActiveRecord::Migration
  def change
    add_column :users, :ability, :text
  end
end
