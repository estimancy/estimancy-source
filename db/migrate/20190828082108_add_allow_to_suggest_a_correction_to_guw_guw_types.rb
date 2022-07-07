class AddAllowToSuggestACorrectionToGuwGuwTypes < ActiveRecord::Migration
  def change
    add_column :guw_guw_types, :allow_to_suggest_a_correction, :boolean
  end
end
