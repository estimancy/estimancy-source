# encoding: UTF-8
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

class AddLdapAttributesToAuthMethods < ActiveRecord::Migration
  def change
    add_column :auth_methods, :on_the_fly_user_creation, :boolean,       :default => false
    add_column :auth_methods, :ldap_bind_dn, :string
    add_column :auth_methods, :ldap_bind_encrypted_password , :string
    add_column :auth_methods, :ldap_bind_salt , :string
    add_column :auth_methods, :priority_order, :integer,      :default => 1
    add_column :auth_methods, :first_name_attribute, :string
    add_column :auth_methods, :last_name_attribute, :string
    add_column :auth_methods, :email_attribute, :string
    add_column :auth_methods, :initials_attribute, :string
  end
end
