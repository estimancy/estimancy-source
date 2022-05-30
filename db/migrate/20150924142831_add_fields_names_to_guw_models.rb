class AddFieldsNamesToGuwModels < ActiveRecord::Migration
  def change
    add_column :guw_guw_models, :coefficient_label, :string
  end
end
