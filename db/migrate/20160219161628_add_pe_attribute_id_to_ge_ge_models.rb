class AddPeAttributeIdToGeGeModels < ActiveRecord::Migration

  def change
    add_column :ge_ge_models, :input_pe_attribute_id, :integer
    add_column :ge_ge_models, :output_pe_attribute_id, :integer
  end

end
