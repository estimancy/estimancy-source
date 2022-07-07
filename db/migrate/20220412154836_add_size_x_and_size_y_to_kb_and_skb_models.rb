class AddSizeXAndSizeYToKbAndSkbModels < ActiveRecord::Migration
  def change
    add_column :skb_skb_datas, :size, :float, after: :name
    add_column :skb_skb_datas, :effort, :float, before: :data

    add_column :skb_skb_inputs, :retained_effort, :float, after: :retained_size

    add_column :kb_kb_datas, :size_x, :float, after: :name
    add_column :kb_kb_datas, :size_y, :float, before: :size

    add_column :kb_kb_inputs, :retained_size, :float, after: :id
    add_column :kb_kb_inputs, :retained_effort, :float, before: :formula

  end
end
