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

# app/controllers/registrations_controller.rb
class RegistrationsController < Devise::RegistrationsController

  def new
    if session["devise.user_attributes"]
      if !session["devise.user_attributes"]['provider'].nil? && session["devise.user_attributes"]['uid'].nil?
        @firstname_with_provider = session["devise.user_attributes"]['first_name']
        @lastname_with_provider = session["devise.user_attributes"]['last_name']
        @login_name_with_provider = session["devise.user_attributes"]['login_name']
        @email_with_provider = session["devise.user_attributes"]['email']
      end
    end

    super
  end

  def create
    super do |resource|
      resource.initials = "your_initials"
      auth_type = AuthMethod.find_by_name('Application')
      everyone_group = Group.find_by_name("Everyone")
      resource.auth_type = auth_type.nil? ? nil : auth_type.id
      resource.groups << everyone_group
      resource.save
    end
  end

  #  #Display help login page
  def help_login
    #No authorize required since everyone can ask for help when logged in
  end

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    resource_updated = update_resource(resource, account_update_params.merge(password_changed: true))
    yield resource if block_given?

    if resource_updated
      #resource.password_changed = true
      #resource.save

      if is_flashing_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
            :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      sign_in resource_name, resource, bypass: true
      respond_with resource, location: after_update_path_for(resource)
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  protected

  def after_update_path_for(resource)
    # if user has no group, he has no rights, so cannot continue
    #if resource.organizations.size == 0
    if resource.organizations.where(is_image_organization: [false, nil]).size == 0
      flash[:warning] = I18n.t(:you_have_no_right_to_continue)
      sign_out(resource)
      new_session_path(:user)
    #elsif resource.organizations.size == 1
    elsif resource.organizations.where(is_image_organization: [false, nil]).size == 1
      organization_estimations_path(resource.organizations.first)
    else
      root_path
    end
  end

  private

  def is_an_automatic_account_activation?
    #No authorize required since this method is protected and won't be call from any route
    begin
      AdminSetting.where(key: 'self-registration').first.value == 'automatic account activation'
    rescue
      false
    end
  end

end