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

class UserMailer < ActionMailer::Base
  default from: SETTINGS['FROM']
  OLD_LOCALE = I18n.locale

  def send_raw_data_extraction(user, organization)
    @organization = organization
    @user = user
    mail(:to => [user.email], :subject => "[ESTIMANCY] - Export des données brutes")
  end

  # send file after export
  def send_extraction_file(user, organization, filename, action_title)
    @organization = organization
    @user = user
    @filename = filename
    @action_title = action_title

    mail(:to => [user.email], :subject => "[ESTIMANCY] - #{action_title}")
  end

  def send_notification(project, estimation_status)
    @project = project
    @estimation_status = estimation_status

    mail(:to => estimation_status.notification_emails.split(", "), :subject => "[ESTIMANCY] - #{@project} - #{@estimation_status.name}")

  end

  def crash_log(exception, user, orga, project)
    if Rails.env == "production"
      @exception = exception
      @backtrace = exception.backtrace
      @user = user
      @current_organization = orga
      @project = project
      mail(:to => ["no-reply@estimancy.com"], :subject => "[ESTIMANCY] - Crash logs #{Time.now}")
    end
  end

  def regular_end_sub_date_checker(email, date_end, day_prev_end, name)
    @day_prev_end = day_prev_end
    @date_end = date_end
    @user_name = name
    mail(:to => email, :subject => "[ESTIMANCY] #{I18n.t(:subscription_end)}")
  end

  def subscription_end(email, name)
    @user_name = name
    mail(:to => email, :subject => "[ESTIMANCY] #{I18n.t(:subscription_end)}")
  end

  def maintenance(users, message, objet)
    @message = message
    unless Rails.env == "development"
      users.map(&:email).each do |email|
        mail(:to => email, :subject => objet)
      end
    end
  end

  #Send the new password
  def forgotten_password(user)
    @user = user
    I18n.locale = user.locale
    mail(:to => @user.email, :subject => I18n.t(:mail_subject_lost_password))
  ensure
    reset_locale
  end

  #Confirm the new password
  def new_password(user)
    @user = user
    I18n.locale = user.locale
    mail(:to => @user.email, :subject => I18n.t(:mail_subject_new_password))
  ensure
    reset_locale
  end

  #Send an account request
  def account_request(status)
    I18n.locale = 'en'
    mail(:to => AdminSetting.find_by_key('notifications_email').value, :subject => I18n.t(:mail_subject_account_activation_request))
  ensure
    reset_locale
  end

  #Confirm validation of account - password is written
  def account_validate(user)
    @user = user
    I18n.locale = user.locale
    mail(:to => @user.email, :subject => I18n.t(:mail_subject_account_activation))
  ensure
    reset_locale
  end

  #Confirm validation of account - the password is not written
  def account_validate_no_pw(user)
    @user = user
    I18n.locale = user.locale
    mail(:to => @user.email, :subject => I18n.t(:mail_subject_account_activation))
  ensure
    reset_locale
  end

  #Notify than account is suspended
  def account_suspended(user)
    @user = user
    I18n.locale = user.locale
    mail(:to => @user.email, :subject => I18n.t(:mail_subject_account_suspended))
  ensure
    reset_locale
  end

  #Confirm validation of account (ldap protocol)
  def account_validate_ldap(user)
    @user = user
    I18n.locale = user.locale
    mail(:to => @user.email, :subject => I18n.t(:mail_subject_account_activation))
  ensure
    reset_locale
  end

  #Account created
  def account_created(user)
    @user = user
    I18n.locale = user.locale
    mail(:to => @user.email, :subject => I18n.t(:mail_subject_account_created))
  ensure
    reset_locale
  end

  #Account created
  def send_feedback(user, type, feedback_message, latest_repo_update, projestimate_version, ruby_version, rails_version, environment, database_adapter, browser, version_browser, platform, os, server_name, root_url)

    @message = "Here a new Feedback from: #{user} \nType: #{type} \n\nMessage: \n\n#{feedback_message} \n\nInformation on environment\n - Latest repository update: #{latest_repo_update} \n - ProjEstimate version: #{projestimate_version} - Ruby version: #{ruby_version} \n - Rails version: #{rails_version} \n - Environment: #{environment} \n - Database adapter: #{database_adapter}\n - Hostname: #{server_name} \n - URL: #{root_url} \n - Browser: #{browser} #{version_browser} (#{platform}) \n - OS: #{os}"
    to = AdminSetting.find_by_key('feedback_email')
    to = to.value
    mail(:to => to, :subject => 'Feedback ('+type+') from '+ user)

  ensure
    reset_locale
  end

  def send_sod(elements)
    @elements = elements
    @organization = Organization.find(@elements[:organization_id])

    begin
      attachments[elements[:devis].original_filename] = elements[:devis].tempfile

      elements[:other_documents].each do |od|
        attachments[od.original_filename] = od.tempfile
      end
      elements[:other_documents2].each do |od|
        attachments[od.original_filename] = od.tempfile
      end
      elements[:other_documents3].each do |od|
        attachments[od.original_filename] = od.tempfile
      end
      elements[:other_documents4].each do |od|
        attachments[od.original_filename] = od.tempfile
      end
      elements[:other_documents5].each do |od|
        attachments[od.original_filename] = od.tempfile
      end
    rescue
    end

    mail(:to => "nicolas.renard@estimancy.com, eric.bellet@estimancy.com, patrick.hamon@estimancy.com", :subject => "Demande de service #{@organization.name} - #{@elements[:contact]}")
  end

  protected
  def reset_locale
    I18n.locale = OLD_LOCALE
  end

end
