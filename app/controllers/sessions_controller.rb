#encoding: utf-8
class SessionsController < Devise::SessionsController

  skip_before_filter :verify_authenticity_token #, only: :create #skip devise to failed when first logged in
  skip_before_action :authenticate_user!

  def new

    set_flash_message(:warning, :invalid, :kind => "request.env['omniauth.auth'] = #{request.env['omniauth.auth']}")

    unless params["SAMLResponse"].nil?
      set_flash_message(:alert, :invalid, :kind => "SAMLResponse non nul = #{params["SAMLResponse"]}")

      response = OneLogin::RubySaml::Response.new(params["SAMLResponse"])

      @user = User.find_for_saml_oauth(response.attributes)

      if @user.nil?
        flash[:warning] = I18n.t("error_access_denied")
        redirect_to root_url
      else
        sign_in_and_redirect @user, :event => :authentication
      end
    else
      set_flash_message(:alert, :invalid, :kind => "SAMLResponse NUL = #{params["SAMLResponse"]}")
      if params['user']
        user = User.where(login_name: params['user']['login_name']).first

        if user
          if devise_mapping.confirmable? && !user.confirmed?
            #set_flash_message(:warning, :unconfirmed, :kind => "Compte non confirme")  #.devise.sessions.user.test
            set_flash_message(:alert, :unconfirmed, :kind => I18n.t('devise.failure.unconfirmed'))  #.devise.sessions.user.test
          elsif user.access_locked?
            set_flash_message(:alert, :locked, :kind => I18n.t('devise.failure.locked'))
          else
            set_flash_message(:alert, :invalid, :kind => I18n.t('devise.failure.invalid'))
            # flash[:error] = resource.errors.full_messages.join('<br />')
            # flash[:alert] = t("devise.failure.#{request.env['warden'].message}") unless request.env['warden'].message.blank?
          end
        else
          flash[:warning] = I18n.t('devise.failure.unknown') #"Identifiant inconnu"
        end
      end

      super
    end
  end


  def new_save
    unless params["SAMLResponse"].nil?

      response = OneLogin::RubySaml::Response.new(params["SAMLResponse"])

      @user = User.find_for_saml_oauth(response.attributes)

      if @user.nil?
        flash[:warning] = I18n.t("error_access_denied")
        redirect_to root_url
      else
        sign_in_and_redirect @user, :event => :authentication
      end
    else
      if params['user']
        user = User.where(login_name: params['user']['login_name']).first

        if user
          if devise_mapping.confirmable? && !user.confirmed?
            #set_flash_message(:warning, :unconfirmed, :kind => "Compte non confirme")  #.devise.sessions.user.test
            set_flash_message(:alert, :unconfirmed, :kind => I18n.t('devise.failure.unconfirmed'))  #.devise.sessions.user.test
          elsif user.access_locked?
            set_flash_message(:alert, :locked, :kind => I18n.t('devise.failure.locked'))
          else
            set_flash_message(:alert, :invalid, :kind => I18n.t('devise.failure.invalid'))
            # flash[:error] = resource.errors.full_messages.join('<br />')
            # flash[:alert] = t("devise.failure.#{request.env['warden'].message}") unless request.env['warden'].message.blank?
          end
        else
          flash[:warning] = I18n.t('devise.failure.unknown') #"Identifiant inconnu"
        end
      end

      super
    end
  end


  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)

    unless resource.subscription_end_date.nil?
      d = Date.parse(resource.subscription_end_date.to_s) - Date.parse(Time.now.to_s)
      case d.to_i
        when 90
          flash[:warning] = I18n.t(:subscription_end_date_has_expired_in, :resource_name => resource.name, :duration => I18n.t('3_months'), :subscription_end_date => resource.subscription_end_date.strftime("%-d %b %Y") )
        when 30
          flash[:warning] = I18n.t(:subscription_end_date_has_expired_in, :resource_name => resource.name, :duration => I18n.t('1_month'), :subscription_end_date => resource.subscription_end_date.strftime("%-d %b %Y") )
        when 15
          flash[:warning] = I18n.t(:subscription_end_date_has_expired_in, :resource_name => resource.name, :duration => I18n.t('15_days'), :subscription_end_date => resource.subscription_end_date.strftime("%-d %b %Y") )
        when 7
          flash[:warning] = I18n.t(:subscription_end_date_has_expired_in, :resource_name => resource.name, :duration => I18n.t('1_week'), :subscription_end_date => resource.subscription_end_date.strftime("%-d %b %Y") )
        when 3
          flash[:warning] = I18n.t(:subscription_end_date_has_expired_in, :resource_name => resource.name, :duration => I18n.t('3_days'), :subscription_end_date => resource.subscription_end_date.strftime("%-d %b %Y") )
        when 2
          flash[:warning] = I18n.t(:subscription_end_date_has_expired_in, :resource_name => resource.name, :duration => I18n.t('3_days'), :subscription_end_date => resource.subscription_end_date.strftime("%-d %b %Y") )
        when 1
          flash[:warning] = I18n.t(:subscription_end_date_has_expired_in, :resource_name => resource.name, :duration => I18n.t('1_day'), :subscription_end_date => resource.subscription_end_date.strftime("%-d %b %Y") )
        else
          if d.to_i <= 0
            flash[:error] = I18n.t(:subscription_end_date_has_expired, :resource_name => resource.name, :subscription_end_date => resource.subscription_end_date.strftime("%-d %b %Y") )
            redirect_to all_organizations_path and return
          end
      end
    end

    if resource.auth_method.name == "Application" || resource.auth_method.name == "SAML"
      set_flash_message(:notice, :signed_in) if is_flashing_format?
      sign_in(resource_name, resource)
      # Monitoring.create(user: current_user.id, action: "Se Connecter", action_at: Time.now + 3600)
      yield resource if block_given?
      if session[:user_return_to].blank?
        location = after_sign_in_path_for(resource)
      else
        location = session[:user_return_to]
      end
      respond_with resource, location: location, :flash => { :error => flash[:error], :warning => flash[:warning] }
    else
      flash[:warning] = "Ce compte est associé à une authentification externe"
      sign_out resource
      redirect_to(root_url, :flash => { :error => flash[:error], :warning => flash[:warning] })
    end
  end

  def destroy
    session[:user_return_to] = nil
    session[:module_project_id] = nil

    #saml
    # Preserve the saml_uid and saml_session_index in the session
    saml_uid = session['saml_uid']
    saml_session_index = session['saml_session_index']

    #end saml
    # Monitoring.create(user: User.current, action: "Se Déconnecter", action_at: Time.now+3600)
    current_user.last_login = Time.now

    #super
    super do
      session['saml_uid'] = saml_uid
      session['saml_session_index'] = saml_session_index
    end
  end

  def after_sign_out_path_for_save()
    if session['saml_uid'] && session['saml_session_index'] && APP_CONFIG['IDP_SLO_TARGET_URL']
      user_saml_omniauth_authorize_path + "/spslo"
    else
      super
    end
  end

  #SAML request with isPassive=true to the IdP
  def verify_connect_with_saml
    resource_name = params[:resource_name]
    login_name = params[:login_name]

    user = User.where(login_name: login_name).first

    if user && user.auth_method.name.to_s == "SAML" && user.organizations.map(&:name).include?("ENEDIS")
      #redirect_to omniauth_authorize_path(resource_name, :saml) and return

      respond_to do |format|
        format.js { render :js => "window.location.href='"+omniauth_authorize_path(resource_name, :saml)+"'" } #and return
        format.html { redirect_to omniauth_authorize_path(resource_name, :saml) and return }
      end
    else
      #redirect_to :back, flash: { alert: "Compte non lié à une authentification SAML"} and return
      respond_to do |format|
        #format.js { redirect_to :back, flash: { alert: "Compte non lié à une authentification SAML"} and return }
        @warning_message = "Compte non lié à une authentification SAML"
        flash[:warning] = @warning_message
        flash.keep[:warning]
        #flash.now[:warning] = "Compte non lié à une authentification SAML"
        format.js { render :js => "window.location.href='"+sign_in_path+"'" and return}
        #format.js {render inline: "location.reload();", flash: { warning: @warning_message } }
        #format.js { flash[:notice] = @warning_message }
        format.html { redirect_to :back, flash: { warning: "Compte non lié à une authentification SAML"} and return }
      end
    end
  end

end