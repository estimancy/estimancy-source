class CreateKpis < ActiveRecord::Migration
  def change
    create_table :kpis, :force => true do |t|
      t.string :kpi_type
      t.integer :organization_id
      t.string :name
      t.text :description
      t.integer :project_id
      t.integer :estimation_model_id
      t.integer :field_id
      t.string :output_type
      t.integer :application_id
      t.integer :project_area_id
      t.integer :project_category_id
      t.integer :platform_category_id
      t.integer :acquisition_category_id
      t.integer :provider_id
      t.integer :nb_last_projects
      t.boolean :include_historized
      t.string  :project_versions
      t.integer :copy_id
      t.boolean :is_selected
      t.string :selected_date
      t.string :kpi_unit
      t.string :position_x
      t.string :position_y
      t.string :width
      t.string :height

      t.timestamps null: false
    end


    create_table :kpi_statuses do |t|
      t.integer :kpi_id
      t.integer :estimation_status_id

      t.timestamps null: false
    end

  end
end
