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

  has_many :users, :foreign_key => 'auth_type'

  belongs_to :record_status

  def to_s
    self.nil? ? '' : self.name
  end
end
