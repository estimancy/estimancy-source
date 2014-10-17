class CreateGuwUnitOfWorkAttributes < ActiveRecord::Migration
  def up
    create_table :guw_guw_unit_of_work_attributes do |t|

      t.integer :low
      t.integer :most_likely
      t.integer :high

      t.integer :guw_type_id
      t.integer :guw_unit_of_work_id
      t.integer :guw_attribute_id
      t.integer :guw_attribute_complexity_id

      t.timestamps
    end

    remove_column :guw_guw_unit_of_works, :low
    remove_column :guw_guw_unit_of_works, :most_likely
    remove_column :guw_guw_unit_of_works, :high
    remove_column :guw_guw_attribute_complexities, :guw_attribute_id

    add_column :guw_guw_unit_of_works, :guw_complexity_id, :integer
    add_column :guw_guw_unit_of_works, :effort, :float
    add_column :guw_guw_unit_of_works, :ajusted_effort, :float
  end

  def down
    drop_table :guw_guw_unit_of_work_attributes

    add_column :guw_guw_unit_of_works, :low, :integer
    add_column :guw_guw_unit_of_works, :most_likely, :integer
    add_column :guw_guw_unit_of_works, :high, :integer
    add_column :guw_guw_attribute_complexities, :guw_attribute_id, :integer

    remove_column :guw_guw_unit_of_works, :guw_complexity_id
    remove_column :guw_guw_unit_of_works, :effort
    remove_column :guw_guw_unit_of_works, :ajusted_effort
  end
end
