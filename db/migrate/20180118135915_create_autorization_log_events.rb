class CreateAutorizationLogEvents < ActiveRecord::Migration
  def change
    # create the log tables
    create_table :autorization_log_events, force: true do |t|
      t.integer :event_organization_id
      t.integer :author_id
      t.string :item_type
      t.integer :item_id
      t.string :association_class_name
      t.string :event
      #t.column :object,  :json
      t.text :object
      t.string :object_class_name
      t.datetime :created_at

      t.text :transaction_id
      #t.column :object_changes, :json
      t.text :object_changes
      t.text :associations_before_changes
      t.text :associations_after_changes

      t.boolean :is_estimation_permission
      t.boolean :is_model_permission
      t.boolean :is_group_security
      t.boolean :is_security_on_created_from_model
      t.integer :organization_id
      t.integer :project_id
      t.integer :group_id
      t.integer :user_id
      t.integer :estimation_status_id
      t.integer :permission_id
      t.integer :project_security_id
      t.integer :project_security_level_id
      t.integer :permissions_project_security_level_id
      t.integer :estimation_status_group_role_id
      t.boolean :from_direct_trigger

      #t.timestamps
    end
  end
end
