class AddFieldsToKbDatas < ActiveRecord::Migration
  def change
    add_column :kb_kb_datas, :project_date, :date
  end
end
