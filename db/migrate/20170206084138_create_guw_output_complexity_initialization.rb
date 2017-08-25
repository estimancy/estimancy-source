class CreateGuwOutputComplexityInitialization < ActiveRecord::Migration
  def change
    begin
      create_table :guw_guw_output_complexity_initializations do |t|
        t.integer :guw_output_id
        t.integer :guw_complexity_id
        t.float :init_value

        t.timestamps
      end
    rescue
      #
    end
  end
end
