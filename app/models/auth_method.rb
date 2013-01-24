#Special table
class AuthMethod < ActiveRecord::Base
  include MasterDataHelper  #Module master data management (UUID generation, deep clone, ...)

  has_many :users, :foreign_key => "auth_type"

  belongs_to :record_status
  belongs_to :owner_of_change, :class_name => "User", :foreign_key => "owner_id"

  validates_presence_of :server_name, :port, :base_dn, :record_status
  validates :uuid, :presence => true, :uniqueness => { :case_sensitive => false }
  validates :name, :presence => true, :uniqueness => { :case_sensitive => false, :scope => :record_status_id }
  validates :custom_value, :presence => true, :if => :is_custom?

  def to_s
    self.name
  end
end
