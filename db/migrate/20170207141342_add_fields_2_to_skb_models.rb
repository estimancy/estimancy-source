class AddFields2ToSkbModels < ActiveRecord::Migration
  def change
    begin
      add_column :skb_skb_datas, :custom_attributes, :text

      add_column :skb_skb_models, :filter_a, :string
      add_column :skb_skb_models, :filter_b, :string
      add_column :skb_skb_models, :filter_c, :string
      add_column :skb_skb_models, :filter_d, :string
      add_column :skb_skb_models, :selected_attributes, :text

      add_column :skb_skb_inputs, :filters, :text
    rescue
      # ignored
    end
  end
end