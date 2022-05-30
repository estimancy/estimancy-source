class AddDescriptionToSkbModels < ActiveRecord::Migration
  def change
    add_column :skb_skb_models, :description, :text
    add_column :skb_skb_datas, :description, :text
  end
end
