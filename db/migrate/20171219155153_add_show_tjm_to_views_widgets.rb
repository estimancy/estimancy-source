class AddShowTjmToViewsWidgets < ActiveRecord::Migration
  def change
    add_column :views_widgets, :show_tjm, :boolean
  end
end
