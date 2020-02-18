class AddFields3ToSkbModels < ActiveRecord::Migration
  def change
    add_column :skb_skb_models, :date_min, :date
    add_column :skb_skb_models, :date_max, :date
    add_column :skb_skb_models, :n_max, :integer

    add_column :skb_skb_datas, :project_date, :date
  end
end
