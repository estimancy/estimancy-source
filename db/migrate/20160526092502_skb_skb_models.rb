class SkbSkbModels < ActiveRecord::Migration
  def change
    create_table "skb_skb_datas", :force => true do |t|
      t.string  "name"
      t.float   "data"
      t.float   "processing"
      t.integer "skb_model_id"
    end

    create_table "skb_skb_inputs", :force => true do |t|
      t.float   "data"
      t.float   "processing"
      t.float    "retained_size"
      t.integer "organization_id"
      t.integer "module_project_id"
      t.integer "skb_model_id"
    end

    create_table "skb_skb_models", :force => true do |t|
      t.string   "name"
      t.string   "size_unit"
      t.boolean  "three_points_estimation"
      t.boolean  "enabled_input"
      t.integer  "organization_id"
      t.integer  "copy_number"
      t.integer  "copy_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
