class DemandAttachment < ActiveRecord::Base
  # mount_uploader :attachment, DemandAttachmentsUploader
  belongs_to :demand
  # validates :name, presence: true
  #selialize :attachment, JSON
end
