class AddDescriptionToIwidgets < ActiveRecord::Migration
  def change
    add_column :iwidgets, :description, :text
  end
end
