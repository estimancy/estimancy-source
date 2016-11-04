class AddFieldsToSkbModels < ActiveRecord::Migration
  def change
    add_column :skb_skb_models, :label_x, :string
    add_column :skb_skb_models, :label_y, :string
  end
end
