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

class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token

  def google_oauth2
    @user = User.find_for_google_oauth2(request.env["omniauth.auth"], current_user)
    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.user_attributes"] = request.env["omniauth.auth"].except('extra') #@user.attributes
      flash[:warning] = I18n.t(:text_almost_done_provide_password_to_finish, kind: "Google")
      redirect_to root_url
    end
  end

  def saml
    auth = request.env['omniauth.auth']

    if auth.nil?

      unless params["SAMLResponse"].nil?

        #env['omniauth.auth'].extra.response_object
        # request = OneLogin::RubySaml::Authrequest.new
        response = OneLogin::RubySaml::Response.new(params["SAMLResponse"])
        @user = User.find_for_saml_oauth(response.attributes)

        if @user.nil?
          flash[:warning] = I18n.t("error_access_denied")
          redirect_to root_url
        else
          #sign_in_and_redirect @user, :event => :authentication
          if @user.persisted?
            sign_in_and_redirect @user, event: :authentication
            set_flash_message(:notice, :success, kind: 'SAML') #if is_navicational_format?
          else
            session['devise.saml_data'] = request.env['omniauth.auth']
            redirect_to root_url and return
          end
        end
      else
        flash[:alert] == I18n.t('devise.failure.unauthenticated')
        redirect_to root_url and return
      end

    else
      @user = User.find_for_saml_oauth(request.env['omniauth.auth'])
      #flash[:notice] = "Response attributes = #{request.env['omniauth.auth']}"

      if @user.nil?
        set_flash_message(:alert, :invalid, kind: "SAML : #{I18n.t("error_access_denied")}")
        redirect_to sign_in_path, warning: "SAML : #{I18n.t(:error_access_denied)}"  and return
      else
        if @user.persisted?
          sign_in_and_redirect @user, event: :authentication
          set_flash_message(:notice, :success, kind: 'SAML') #if is_navicational_format?
          #return unless flash[:alert].blank? || flash[:alert] == I18n.t('devise.failure.unauthenticated')
        else
          session['devise.saml_data'] = request.env['omniauth.auth']
          redirect_to root_url and return
        end
      end
    end
  end


  def saml_enedis
    auth = request.env['omniauth.auth']

    if auth.nil?

      unless params["SAMLResponse"].nil?

        #env['omniauth.auth'].extra.response_object
        # request = OneLogin::RubySaml::Authrequest.new
        response = OneLogin::RubySaml::Response.new(params["SAMLResponse"])
        #@user = User.find_for_saml_oauth(response.attributes)
        @user = User.find_for_saml_oauth_with_onelogin(response.attributes)

        if @user.nil?
          flash[:warning] = I18n.t("error_access_denied")
          redirect_to root_url
        else
          #sign_in_and_redirect @user, :event => :authentication
          if @user.persisted?
            sign_in_and_redirect @user, event: :authentication
            set_flash_message(:notice, :success, kind: 'SAML') #if is_navicational_format?
          else
            session['devise.saml_data'] = request.env['omniauth.auth']
            redirect_to root_url and return
          end
        end
      else
        flash[:alert] == I18n.t('devise.failure.unauthenticated')
        redirect_to root_url and return
      end

    else
      @user = User.find_for_saml_oauth(request.env['omniauth.auth'])
      #flash[:notice] = "Response attributes = #{request.env['omniauth.auth']}"

      if @user.nil?
        set_flash_message(:alert, :invalid, kind: "SAML : #{I18n.t("error_access_denied")}")
        redirect_to sign_in_path, warning: "SAML : #{I18n.t(:error_access_denied)}"  and return
      else
        if @user.persisted?
          sign_in_and_redirect @user, event: :authentication
          set_flash_message(:notice, :success, kind: 'SAML') #if is_navicational_format?
          #return unless flash[:alert].blank? || flash[:alert] == I18n.t('devise.failure.unauthenticated')
        else
          session['devise.saml_data'] = request.env['omniauth.auth']
          redirect_to root_url and return
        end
      end
    end
  end


  def before_request_phase()
    #OmniAuth.config.before_request_phase = block
    puts "test"
  end

  # def request_phase
  #   if env['rack.session']['warden.user.user.key'].present?
  #     super
  #   else
  #     redirect '/'
  #   end
  # end

  def failure
    #return unless flash[:alert].blank? || flash[:alert] == I18n.t('devise.failure.unauthenticated')
    flash[:alert] == I18n.t('devise.failure.unauthenticated')
    redirect_to root_path
  end

end
