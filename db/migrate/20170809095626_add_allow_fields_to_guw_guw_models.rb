class AddAllowFieldsToGuwGuwModels < ActiveRecord::Migration
  def change
    add_column :guw_guw_models, :allow_excel, :boolean
    add_column :guw_guw_models, :allow_jira, :boolean
    add_column :guw_guw_models, :allow_redmine, :boolean
  end
end
