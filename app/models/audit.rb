# -*- coding: utf-8 -*-
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
class Audit < ActiveRecord::Base
  # attr_accessible :title, :body

  serialize :audited_changes, Hash

  def customize_action_name
    audit_action = ""
    if action
      case action
        when "create"
          audit_action = "Création"
        when "update"
          audit_action = "Modification"
        when "delete"
          audit_action = "Suppression"
      end
    end
    return audit_action
  end

  # customize the changes
  def customize_audited_changes
    changes = ""
    if action && audited_changes
      case action
        when "create"
          changes = "Création d'un nouvel objet '#{auditable_type}' (id = #{auditable_id})"
        when "update"
          audited_value = audited_changes
          changed_attribute = audited_value[audited_value.keys.first]
          changes = "Modification de la valeur du champ '#{audited_changes.keys.first}' de '#{changed_attribute.first}' à '#{changed_attribute.last}' "
        when "delete"
          changes = "Suppression"
      end
    end
    return changes
  end

  def customize_user_id
    user_login = ""
    begin
      if user_id
        user = User.find(user_id)
        if user
          user_login = "#{user.login_name}"
        end
      end
    rescue
      user_login = "Introuvable"
    end

    return user_login
  end

end


