class CreateGuwGuwOutputTypes < ActiveRecord::Migration
  def change
    begin
      create_table :guw_guw_output_types do |t|
        t.integer :guw_model_id
        t.integer :guw_output_id
        t.integer :guw_type_id
        t.string :display_type, default: "display"

        t.timestamps
      end
    rescue
      #
    end
  end
end
