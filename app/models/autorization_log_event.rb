class AutorizationLogEvent < ActiveRecord::Base
  attr_accessible :author_id, :created_at, :estimation_status_group_role_id, :estimation_status_id, :event, :group_id, :is_group_security,
                  :is_model_security, :is_project_security, :is_security_on_created_from_model, :item_id, :item_type,
                  :object, :object_changes, :organization_id, :permission_id, :permissions_project_security_level_id,
                  :project_id, :project_security_id, :project_security_level_id, :transaction_id, :user_id,
                  :association_class_name, :associations_before_changes, :associations_after_changes, :object_class_name,
                  :event_organization_id, :transaction_id

  serialize :object_changes, Hash
  serialize :object, Hash
  serialize :associations_before_changes, Array
  serialize :associations_after_changes, Array

  belongs_to :organization
  belongs_to :author, foreign_key: :author_id, class_name: "User"
  belongs_to :user
  belongs_to :group
  belongs_to :project
  belongs_to :estimation_status
  belongs_to :permission
  belongs_to :project_security
  belongs_to :project_security_level
  belongs_to :permissions_project_security_level
  belongs_to :estimation_status_group_role
end
