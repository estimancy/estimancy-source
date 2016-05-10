#encoding: utf-8
#############################################################################
#
# Estimancy, Open Source project estimation web application
# Copyright (c) 2014 Estimancy (http://www.estimancy.com)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################

class AuthMethod < ActiveRecord::Base

  attr_accessible :name, :server_name, :port, :base_dn, :user_name_attribute,
                  :owner_id, :on_the_fly_user_creation, :ldap_bind_dn, :password,
                  :ldap_bind_encrypted_password, :ldap_bind_salt, :priority_order,
                  :first_name_attribute, :last_name_attribute, :email_attribute,
                  :initials_attribute, :encryption, :record_status_id, :custom_value, :change_comment

  attr_accessor :password

  #include MasterDataHelper #Module master data management (UUID generation, deep clone, ...)

  has_many :users, :foreign_key => 'auth_type'

  #belongs_to :record_status
  #belongs_to :owner_of_change, :class_name => 'User', :foreign_key => 'owner_id'

  # before_save :encrypt_password

  #validates :uuid, :presence => true, :uniqueness => {:case_sensitive => false}
  #validates :name, :presence => true, :uniqueness => {:case_sensitive => false, :scope => :record_status_id}
  #validates :custom_value, :presence => true, :if => :is_custom?
  #validate :validate_if_fly_user_creation, :if => :on_the_fly_user_creation

  # amoeba do
  #   enable
  #   exclude_association [:users]
  #
  #   customize(lambda { |original_record, new_record|
  #     new_record.reference_uuid = original_record.uuid
  #     new_record.reference_id = original_record.id
  #     new_record.record_status = RecordStatus.find_by_name('Proposed')
  #   })
  # end

  # def validate_if_fly_user_creation
  #   errors.add(:first_name_attribute, "#{I18n.t('warning_on_the_fly_user_creation')}") if first_name_attribute.blank?
  #   errors.add(:last_name_attribute,  "#{I18n.t('warning_on_the_fly_user_creation')}")  if last_name_attribute.blank?
  #   errors.add(:email_attribute,  "#{I18n.t('warning_on_the_fly_user_creation')}")  if email_attribute.blank?
  # end

  # def encrypt_password
  #   if self.password.present?
  #     encrypted_data = AESCrypt.encrypt(password, 'yourpass')
  #     self.ldap_bind_encrypted_password = encrypted_data
  #   end
  # end

  # def encryption2
  #   case self.encryption
  #     when 'No encryption'
  #       return ''
  #     when 'SSL (ldaps://)'
  #       return :simple_tls
  #     when 'StartTLS'
  #       return :start_tls
  #     else
  #       return ''
  #   end
  # end

  # def decrypt_password
  #   return AESCrypt.decrypt(self.ldap_bind_encrypted_password,'yourpass')
  # end

  def to_s
    self.nil? ? '' : self.name
  end
end
