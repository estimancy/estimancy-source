#encoding: utf-8
class SessionsController < Devise::SessionsController

  def new
    unless params["SAMLResponse"].nil?

      response = OneLogin::RubySaml::Response.new(params["SAMLResponse"])

      #if response.is_valid?
      #  logger.info "Réponse valide"
      #end
      #logger.info response.inspect

      #session[:userid] = response.nameid
      #session[:attributes] = response.attributes

      @user = User.find_for_saml_oauth(response.attributes)
      if @user.nil?
        flash[:warning] = I18n.t("error_access_denied")
        redirect_to root_url
      else
        sign_in_and_redirect @user, :event => :authentication
        #set_flash_message(:notice, :success, :kind => "SNCF SAML") if is_navigational_format?
      end
    else
      if params['user']
        user = User.where(login_name: params['user']['id_connexion']).first

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

    if resource.auth_method.name == "Application"
      set_flash_message(:notice, :signed_in) if is_flashing_format?
      sign_in(resource_name, resource)
      Monitoring.create(user: current_user.id, action: "Se Connecter", action_at: Time.now+3600)
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