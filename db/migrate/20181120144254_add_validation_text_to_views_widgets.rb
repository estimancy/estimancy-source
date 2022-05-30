class AddValidationTextToViewsWidgets < ActiveRecord::Migration
  def change
    add_column :views_widgets, :validation_text, :string
  end
end
