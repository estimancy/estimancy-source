# -*- coding: utf-8 -*-
# Devise configuration File
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


# Use this hook to configure devise mailer, warden hooks and so forth.
# Many of these configuration options can be set straight in your model.
Devise.setup do |config|
  # ==> LDAP Configuration 
  # config.ldap_logger = true
  # config.ldap_create_user = false
  # config.ldap_update_password = true
  # config.ldap_config = "#{Rails.root}/config/ldap.yml"
  # config.ldap_check_group_membership = false
  # config.ldap_check_group_membership_without_admin = false
  # config.ldap_check_attributes = false
  # config.ldap_use_admin_to_bind = false
  # config.ldap_ad_group_check = false

  # The secret key used by Devise. Devise uses this key to generate
  # random tokens. Changing this key will render invalid all existing
  # confirmation, reset password and unlock tokens in the database.
  config.secret_key = '68d4097ba247cbd339d67155e6cd2d4d837b0bc1cdc1005ccf3b95712a74ca2f31a38225e43a130d2bbccd36b94b2cc1a2130836dd52aef629ad28ccf3782a30'

  # ==> Mailer Configuration
  # Configure the e-mail address which will be shown in Devise::Mailer,
  # note that it will be overwritten if you use your own mailer class
  # with default "from" parameter.
  config.mailer_sender = 'no-reply@estimancy.com'

  # Configure the class responsible to send e-mails.
  # config.mailer = 'Devise::Mailer'

  # ==> ORM configuration
  # Load and configure the ORM. Supports :active_record (default) and
  # :mongoid (bson_ext recommended) by default. Other ORMs may be
  # available as additional gems.
  require 'devise/orm/active_record'

  # ==> Configuration for any authentication mechanism
  # Configure which keys are used when authenticating a user. The default is
  # just :email. You can configure it to use [:username, :subdomain], so for
  # authenticating a user, both parameters are required. Remember that those
  # parameters are used only when authenticating and not when retrieving from
  # session. If you need permissions, you should implement that in a before filter.
  # You can also supply a hash where the value is a boolean determining whether
  # or not authentication should be aborted when the value is not present.
  # config.authentication_keys = [ :email ]
  config.authentication_keys = [ :login_name ]
  # config.authentication_keys = [ :id_connexion ]

  # Configure parameters from the request object used for authentication. Each entry
  # given should be a request method and it will automatically be passed to the
  # find_for_authentication method and considered in your model lookup. For instance,
  # if you set :request_keys to [:subdomain], :subdomain will be used on authentication.
  # The same considerations mentioned for authentication_keys also apply to request_keys.
  # config.request_keys = []

  # Configure which authentication keys should be case-insensitive.
  # These keys will be downcased upon creating or modifying a user and when used
  # to authenticate or find a user. Default is :email.
  #config.case_insensitive_keys = [ :email ]

  # Configure which authentication keys should have whitespace stripped.
  # These keys will have whitespace before and after removed upon creating or
  # modifying a user and when used to authenticate or find a user. Default is :email.
  #config.strip_whitespace_keys = [ :email ]

  # Tell if authentication through request.params is enabled. True by default.
  # It can be set to an array that will enable params authentication only for the
  # given strategies, for example, `config.params_authenticatable = [:database]` will
  # enable it only for database (email + password) authentication.
  # config.params_authenticatable = true

  # Tell if authentication through HTTP Auth is enabled. False by default.
  # It can be set to an array that will enable http authentication only for the
  # given strategies, for example, `config.http_authenticatable = [:database]` will
  # enable it only for database authentication. The supported strategies are:
  # :database      = Support basic authentication with authentication key + password
  # config.http_authenticatable = false

  # If http headers should be returned for AJAX requests. True by default.
  # config.http_authenticatable_on_xhr = true

  # The realm used in Http Basic Authentication. 'Application' by default.
  # config.http_authentication_realm = 'Application'

  # It will change confirmation, password recovery and other workflows
  # to behave the same regardless if the e-mail provided was right or wrong.
  # Does not affect registerable.
  # config.paranoid = true

  # By default Devise will store the user in session. You can skip storage for
  # particular strategies by setting this option.
  # Notice that if you are skipping storage for all authentication paths, you
  # may want to disable generating routes to Devise's sessions controller by
  # passing skip: :sessions to `devise_for` in your config/routes.rb
  config.skip_session_storage = [:http_auth]

  # By default, Devise cleans up the CSRF token on authentication to
  # avoid CSRF token fixation attacks. This means that, when using AJAX
  # requests for sign in and sign up, you need to get a new CSRF token
  # from the server. You can disable this option at your own risk.
  # config.clean_up_csrf_token_on_authentication = true

  # ==> Configuration for :database_authenticatable
  # For bcrypt, this is the cost for hashing the password and defaults to 10. If
  # using other encryptors, it sets how many times you want the password re-encrypted.
  #
  # Limiting the stretches to just one in testing will increase the performance of
  # your test suite dramatically. However, it is STRONGLY RECOMMENDED to not use
  # a value less than 10 in other environments. Note that, for bcrypt (the default
  # encryptor), the cost increases exponentially with the number of stretches (e.g.
  # a value of 20 is already extremely slow: approx. 60 seconds for 1 calculation).
  config.stretches = Rails.env.test? ? 1 : 10

  # Setup a pepper to generate the encrypted password.
  # config.pepper = 'd37b88c1472073ff9ddf77e614a9a1f5b5030eaf7ff6d7f23a4a7a4300a6260ad840d58dc83ac39687693c08be46b57e81e4534254c4b7b1e94745ac57904534'

  # ==> Configuration for :confirmable
  # A period that the user is allowed to access the website even without
  # confirming their account. For instance, if set to 2.days, the user will be
  # able to access the website for two days without confirming their account,
  # access will be blocked just in the third day. Default is 0.days, meaning
  # the user cannot access the website without confirming their account.
  # config.allow_unconfirmed_access_for = 2.days

  # A period that the user is allowed to confirm their account before their
  # token becomes invalid. For example, if set to 3.days, the user can confirm
  # their account within 3 days after the mail was sent, but on the fourth day
  # their account can't be confirmed with the token any more.
  # Default is nil, meaning there is no restriction on how long a user can take
  # before confirming their account.
  # config.confirm_within = 3.days

  # If true, requires any email changes to be confirmed (exactly the same way as
  # initial account confirmation) to be applied. Requires additional unconfirmed_email
  # db field (see migrations). Until confirmed, new email is stored in
  # unconfirmed_email column, and copied to email column on successful confirmation.
  config.reconfirmable = true

  # Defines which key will be used when confirming an account
  # config.confirmation_keys = [ :email ]
  config.confirmation_keys = [ :login_name ]

  # ==> Configuration for :rememberable
  # The time the user will be remembered without asking for credentials again.
  # config.remember_for = 2.weeks
  config.remember_for = 2.weeks

  # If true, extends the user's remember period when remembered via cookie.
  # config.extend_remember_period = false

  # Options to be passed to the created cookie. For instance, you can set
  # secure: true in order to force SSL only cookies.
  # config.rememberable_options = {}

  # ==> Configuration for :validatable
  # Range for password length.
  config.password_length = 8..128

  # Email regex used to validate email formats. It simply asserts that
  # one (and only one) @ exists in the given string. This is mainly
  # to give user feedback and not to assert the e-mail validity.
  # config.email_regexp = /\A[^@]+@[^@]+\z/

  # ==> Configuration for :timeoutable
  # The time you want to timeout the user session without activity. After this
  # time the user will be asked for credentials again. Default is 30 minutes.
  # config.timeout_in = 30.minutes
  config.timeout_in = 1.week

  # If true, expires auth token on session timeout.
  # config.expire_auth_token_on_timeout = false

  # ==> Configuration for :lockable
  # Defines which strategy will be used to lock an account.
  # :failed_attempts = Locks an account after a number of failed attempts to sign in.
  # :none            = No lock strategy. You should handle locking by yourself.
  # config.lock_strategy = :failed_attempts

  # Defines which key will be used when locking and unlocking an account
  # config.unlock_keys = [ :email ]

  # Defines which strategy will be used to unlock an account.
  # :email = Sends an unlock link to the user email
  # :time  = Re-enables login after a certain amount of time (see :unlock_in below)
  # :both  = Enables both strategies
  # :none  = No unlock strategy. You should handle unlocking by yourself.
  # config.unlock_strategy = :both

  # Number of authentication tries before locking an account if lock_strategy
  # is failed attempts.
   config.maximum_attempts = 10

  # Time interval to unlock the account if :time is enabled as unlock_strategy.
  # config.unlock_in = 1.hour

  # Warn on the last attempt before the account is locked.
  config.last_attempt_warning = false

  # ==> Configuration for :recoverable
  #
  # Defines which key will be used when recovering the password for an account
  # config.reset_password_keys = [ :email ]
  config.reset_password_keys = [ :login_name ]

  # Time interval you can reset your password with a reset password key.
  # Don't put a too small interval or your users won't have the time to
  # change their passwords.
  config.reset_password_within = 6.hours

  # ==> Configuration for :encryptable
  # Allow you to use another encryption algorithm besides bcrypt (default). You can use
  # :sha1, :sha512 or encryptors from others authentication tools as :clearance_sha1,
  # :authlogic_sha512 (then you should set stretches above to 20 for default behavior)
  # and :restful_authentication_sha1 (then you should set stretches to 10, and copy
  # REST_AUTH_SITE_KEY to pepper).
  #
  # Require the `devise-encryptable` gem when using anything other than bcrypt
  # config.encryptor = :sha512

  # ==> Scopes configuration
  # Turn scoped views on. Before rendering "sessions/new", it will first check for
  # "users/sessions/new". It's turned off by default because it's slower if you
  # are using only default views.
  # config.scoped_views = false
  config.scoped_views = true

  # Configure the default scope given to Warden. By default it's the first
  # devise role declared in your routes (usually :user).
  # config.default_scope = :user

  # Set this configuration to false if you want /users/sign_out to sign out
  # only the current scope. By default, Devise signs out all scopes.
  # config.sign_out_all_scopes = true

  # ==> Navigation configuration
  # Lists the formats that should be treated as navigational. Formats like
  # :html, should redirect to the sign in page when the user does not have
  # access, but formats like :xml or :json, should return 401.
  #
  # If you have any extra navigational formats, like :iphone or :mobile, you
  # should add them to the navigational formats lists.
  #
  # The "*/*" below is required to match Internet Explorer requests.
  # config.navigational_formats = ['*/*', :html]

  # The default HTTP method used to sign out a resource. Default is :delete.
  config.sign_out_via = :delete

  # ==> OmniAuth
  # Add a new OmniAuth provider. Check the wiki for more information on setting
  # up on your models and hooks.
  # config.omniauth :github, 'APP_ID', 'APP_SECRET', scope: 'user,public_repo'
  ###config.omniauth :google_oauth2, "504921486051.apps.googleusercontent.com", "AIzaSyDBsz9qmhKS8oalbkJwTqKsBi8yKAnfwmw", { access_type: "offline", approval_prompt: "Acceptez-vous de vous connecter à ProjEstimate via votre compte Google" }

CERTIFICATE =<<CERTIFICATE
-----BEGIN CERTIFICATE-----
MIIDFDCCAfygAwIBAgIEVLPsKDANBgkqhkiG9w0BAQ0FADBMMQswCQYDVQQGEwJGUjENMAsGA1UE CgwEU05DRjENMAsGA1UECwwERFNJVDEfMB0GA1UEAwwWaWRwLXNpZ25hdHVyZS0yMDE0LWRldjAe Fw0xNTAxMTIxNTQ2NThaFw0yNTAxMTIxNTQ2NThaMEwxCzAJBgNVBAYTAkZSMQ0wCwYDVQQKDART TkNGMQ0wCwYDVQQLDAREU0lUMR8wHQYDVQQDDBZpZHAtc2lnbmF0dXJlLTIwMTQtZGV2MIIBIjAN BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArV7qnTenVeZwYP4m0ji5xbsFvqNRTW8+i0Ys98oB VKlWJpEXdPUQMBi4TdjHPUBRmueW74v1v8Uw+1NeE8WvI0bStvH7P2zxeP5bdL6onVNIZUdb1L1l kBjlYQP30TtsRZuJ2d+vmf3BKEvtd3V47A8gSuAJO9q8dT+Rby7ZOMWw/ZU/dJTIGplhgpJlQMXi 3wLZyHU+oi7V5PmRE0ZYEn0LLXtQXQj1bYW+5AjU6TykXQVqISqImGiONpnKQYkOgZ56vXR9nU+/ ZSmyc/VTBTnA0Xwj/aWfOokaFqft0LhH1gykhq9IIgHaxo55SqRm4lymxx13Hpe1lA3BlWzWVQID AQABMA0GCSqGSIb3DQEBDQUAA4IBAQCisxQCBp26pa52WPq5l0srOO6kfq0oNi/6IWKlQQF0p8MV gsH+ITyHd59h5b5JXXUirL+FzpTHiabLVcSkA2rG+jfuqCGTMtXZiANUEkmlNa8NAmDHwOPe19fL SFl7duFE5BacS4IYf6zPFkpMNBMBJdQlud+chuiKpdYQanSN2Vr+ZEUQlYddkUFZUGIKpw3LpwRP dSdxoqNyHr4u+j5yOXWzaRtZpaw7zMPNT+YAB6shmpVSsbwJ1xRE34t1hj3UV/44XnnvXWCqUjsp yUje5NYfEh8ehf5Ysv6kToXM9fTyKWJhx+ip/lnSIzNe1bFjGXesSmYGtapu6htcLF2m
-----END CERTIFICATE-----
CERTIFICATE

  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

  config.omniauth :google_oauth2, "504921486051-vb2gi8tfaff5hqgnnosamjto3sv5gabp.apps.googleusercontent.com", "wLnNbhyZGrdkcjnxWe95SRr7", { access_type: "offline", approval_prompt: I18n.t(:text_ask_connect_to_estimancy_via_google) }
  config.omniauth :saml,
                  idp_cert_fingerprint: 'fingerprint',
                  idp_sso_target_url: APP_CONFIG['IDP_SSO_TARGET_URL'],
                  issuer: APP_CONFIG['ISSUER'],
                  :assertion_consumer_service_url => APP_CONFIG['ASSERTION_CONSUMER_SERVICE_URL'],
                  :name_identifier_format => APP_CONFIG['NAME_IDENTIFIER_FORMAT'],
                  :idp_cert => CERTIFICATE,
                  :idp_sso_target_url_runtime_params  => { :original_request_param => :mapped_idp_param }

  # ==> Warden configuration
  # If you want to use other strategies, that are not supported by Devise, or
  # change the failure app, you can configure them inside the config.warden block.
  #
  # config.warden do |manager|
  #   manager.intercept_401 = false
  #   manager.default_strategies(scope: :user).unshift :some_external_strategy
  # end

  # ==> Mountable engine configurations
  # When using Devise inside an engine, let's call it `MyEngine`, and this engine
  # is mountable, there are some extra configurations to be taken into account.
  # The following options are available, assuming the engine is mounted as:
  #
  #     mount MyEngine, at: '/my_engine'
  #
  # The router that invoked `devise_for`, in the example above, would be:
  # config.router_name = :my_engine
  #
  # When using omniauth, Devise cannot automatically set Omniauth path,
  # so you need to do it manually. For the users scope, it would be:
  # config.omniauth_path_prefix = '/my_engine/users/auth'
end