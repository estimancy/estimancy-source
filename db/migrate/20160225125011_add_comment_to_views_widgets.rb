class AddCommentToViewsWidgets < ActiveRecord::Migration
  def change
    add_column :views_widgets, :comment, :text
  end
end
