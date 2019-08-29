class AddAllowAddToKnowledgeDbToGuwGuwTypes < ActiveRecord::Migration
  def change
    add_column :guw_guw_types, :allow_to_add_to_knowledge_db, :boolean
  end
end
