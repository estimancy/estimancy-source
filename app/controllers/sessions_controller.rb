#encoding: utf-8
class SessionsController < Devise::SessionsController

  def new
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
            set_flash_message(:warning, :unconfirmed, :kind => "Compte non confirme")  #.devise.sessions.user.test
          elsif user.access_locked?
            set_flash_message(:warning, :locked, :kind => "Compte bloque")
          end
        else
          flash[:warning] = "Identifiant inconnu"
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
            redirect_to organizationals_params_path and return
          end
      end
    end

    if resource.auth_method.name == "Application"
      set_flash_message(:notice, :signed_in) if is_flashing_format?
      sign_in(resource_name, resource)
      Monitoring.create(user: current_user.id, action: "Se Connecter", action_at: Time.now + 3600)
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
    Monitoring.create(user: User.current, action: "Se Déconnecter", action_at: Time.now+3600)
    current_user.last_login = Time.now
    super
  end

end