class AddAllowManToGuwGuwModels < ActiveRecord::Migration
  def change
    add_column :guw_guw_models, :allow_excel, :boolean
    add_column :guw_guw_models, :allow_jira, :boolean
    add_column :guw_guw_models, :allow_redmine, :boolean

    add_column :guw_guw_models, :excel_ml_server, :string
    add_column :guw_guw_models, :jira_ml_server, :string
    add_column :guw_guw_models, :redmine_ml_server, :string

    add_column :guw_guw_models, :allow_ml_excel, :boolean
    add_column :guw_guw_models, :allow_ml_jira, :boolean
    add_column :guw_guw_models, :allow_ml_redmine, :boolean
  end
end
