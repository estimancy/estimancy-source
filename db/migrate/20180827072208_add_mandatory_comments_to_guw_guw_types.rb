class AddMandatoryCommentsToGuwGuwTypes < ActiveRecord::Migration
  def change
    add_column :guw_guw_types, :mandatory_comments, :boolean, default: true
  end
end
