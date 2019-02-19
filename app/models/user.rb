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

require 'net/ldap'

# User of the application. User has many projects, groups, permissions and project securities. User have one language
class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :timeoutable, :lockable,# :saml_authenticatable, :trackable,
         :recoverable, :rememberable,
         :confirmable, # account confirmation
         :omniauthable, :omniauth_providers => [:google_oauth2, :saml],
         :authentication_keys => [:id_connexion]

  validates_presence_of :password, :on => :create
  validates_confirmation_of :password, :on => :create
  validates_length_of :password, :within => Devise.password_length, :allow_blank => true
  validates_format_of :email, :with  => Devise.email_regexp, :allow_blank => true, :if => :email_changed?

  attr_accessible :current_password, :email, :login_name, :id_connexion, :super_admin, :password_changed,
                  :password, :password_confirmation, :remember_me, :provider, :uid, :description,
                  :avatar, :language_id, :first_name, :last_name, :initials, :time_zone, :locked_at,
                  :object_per_page, :password_salt, :password_hash, :password_reset_token, :auth_token, :created_at,
                  :updated_at, :auth_type, :number_precision, :subscription_end_date, :transaction_id, :last_login, :previous_login

  # Virtual attribute for authenticating by either login_name or email  # This is in addition to a real persisted field like 'login_name'
  attr_accessor :id_connexion, :updating_password, :current_password

  # Hair-Triggers

  # Get the current user in model
  def self.current
    Thread.current[:user]
  end
  def self.current=(user)
    Thread.current[:user] = user
  end

  has_and_belongs_to_many :projects
  has_and_belongs_to_many :permissions
  ###has_and_belongs_to_many :organizations  ##to comment if not working

  belongs_to :language, :foreign_key => 'language_id', :touch => true
  belongs_to :auth_method, :foreign_key => 'auth_type', :touch => true

  has_many :project_securities
  has_many :wbs_project_elements, :foreign_key => 'author_id' ###has_many :authors, :foreign_key => 'author_id', :class_name => 'WbsProjectElement'
  has_one :creator, :class_name => 'User', :foreign_key => 'creator_id'

  has_many :groups_users, class_name: 'GroupsUsers'
  has_many :groups, through: :groups_users, :source => :group

  #has_many :organizations, through: :groups, :uniq => true

  #For user without group
  has_many :organizations_users, class_name: 'OrganizationsUsers'
  has_many :organizations, through: :organizations_users, :source => :organization#, uniq: true

  #Master and Special Data Tables
  # has_many :change_on_acquisition_categories, :foreign_key => 'owner_id', :class_name => 'AcquisitionCategory'
  # has_many :change_on_attributes, :foreign_key => 'owner_id', :class_name => 'PeAttribute'
  # has_many :change_on_attribute_modules, :foreign_key => 'owner_id', :class_name => 'AttributeModule'
  # has_many :change_on_currencies, :foreign_key => 'owner_id', :class_name => 'Currency'
  # has_many :change_on_event_types, :foreign_key => 'owner_id', :class_name => 'EventType'
  # has_many :change_on_languages, :foreign_key => 'owner_id', :class_name => 'Language'
  # has_many :change_on_pemodules, :foreign_key => 'owner_id', :class_name => 'Pemodule'
  # has_many :change_on_platform_categories, :foreign_key => 'owner_id', :class_name => 'PlatformCategory'
  # has_many :change_on_project_areas, :foreign_key => 'owner_id', :class_name => 'ProjectArea'
  # has_many :change_on_project_categories, :foreign_key => 'owner_id', :class_name => 'ProjectCategory'
  # has_many :change_on_project_security_levels, :foreign_key => 'owner_id', :class_name => 'ProjectSecurityLevel'
  # has_many :change_on_record_statuses, :foreign_key => 'owner_id', :class_name => 'RecordStatus'
  # has_many :change_on_work_element_types, :foreign_key => 'owner_id', :class_name => 'WorkElementType'
  #
  # has_many :change_on_admin_settings, :foreign_key => 'owner_id', :class_name => 'AdminSetting'
  # has_many :change_on_auth_methods, :foreign_key => 'owner_id', :class_name => 'AuthMethod'
  # has_many :change_on_groups, :foreign_key => 'owner_id', :class_name => 'Group'
  # has_many :change_on_permissions, :foreign_key => 'owner_id', :class_name => 'Permission'

  has_many :estimations, :foreign_key => 'creator_id', :class_name => 'Project'

  serialize :ten_latest_projects, Array

  # Security Audit management
  # has_paper_trail only: [:super_admin], meta: { organization_id: :organization_id}

  validates_presence_of :last_name, :first_name
  validates :login_name, :presence => true, :uniqueness => { case_sensitive: false }
  validates :email, :presence => true ###, :format => {:with => /\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/i}, :uniqueness => {case_sensitive: false}
  #validates :email, :presence => true, :format => {:with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i}#, :uniqueness => {case_sensitive: false}
  validates :number_precision, numericality: { only_integer: true, :allow_blank => true }

  #validates :password, :presence => {:on => :create}, :confirmation => true, :if => :auth_method_application?
  validates :password, :presence => true, :if => :should_validate_password?
  validates :password, :confirmation => true, :if => :auth_method_application?

  validates :password_confirmation, :presence => {:on => :create}, :if => :auth_method_application?
  validate :password_length, :on => :create, :if => 'password.present?'

  #Search fields
  scoped_search :on => [:last_name, :first_name, :login_name, :created_at, :updated_at]
  scoped_search :relation => :groups, :on => :name
  scoped_search :relation => :organizations, :on => :name

  scope :exists, lambda { |login|
    where('email >= ? OR login_name < ?', login, login)
  }

  def should_validate_password?
    updating_password || new_record?
  end

  # Customize the devise password validations
  protected
  def password_required?
    #false
    updating_password || new_record?
  end

  # Devise confirmation
  def confirmation_required?
    self.provider.nil?
  end

  public

  ####====================================== AUTHENTICATION METHODS ============================================================

  # Default auth_method is "Application"
  def auth_method_application?
    begin
      self.auth_method.name == 'Application'
    rescue
      false
    end
  end

  def is_an_automatic_account_activation?
    as = AdminSetting.where(key 'self-registration').first.value
    as == 'automatic account activation'
  end


  #Check password minimum length value
  def password_length
    begin
      password_length = default_password_length = 4
      user_as = AdminSetting.find_by_key('password_min_length')
      if !user_as.nil?
        password_length = user_as.value.to_i
      end
      password_length
    rescue
      password_length
    end
    if self.password.length < password_length
      errors.add(:password, "password is too short (minimum is #{password_length} characters)")
    end
  end

  # DEVISE : override the find_first_by_auth_conditions method, as we want to use both 'login_name' and 'email' for authentication
  #without case_sensitive = false
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:id_connexion)
    if login
      where(conditions).where(conditions).where(["login_name = :value", { :value => login }]).first
    else
      where(conditions).first
    end
  end

  # GOOGLE AUTHENTICATION FROM DEVISE
  ####def self.from_omniauth(auth)
  def self.find_for_google_oauth2(auth, signed_in_resource=nil)
    user = User.find_by_email(auth.info.email)
    if user
      user.provider = auth.provider
      user.uid = auth.uid
      user
    else
      where(auth.slice(:provider, :uid)).first_or_create do |user|
        user.provider = auth.provider
        user.uid = auth.uid
        user.login_name = auth.info.name
        user.first_name = auth.info.first_name
        user.last_name = auth.info.last_name
        user.email = auth.info.email
        user.avatar = auth.info.image
        user.password = Devise.friendly_token[0,20]
      end
    end
  end

  def self.find_for_saml_oauth(attributes)
    user = User.find_by_login_name(attributes["cn"])
    if user
      user.provider = "SAML"
      user
    else
    #  where(auth.slice(:provider, :uid)).first_or_create do |user|
    #    user.provider = auth.provider
    #    user.uid = auth.uid
    #    user.login_name = auth.info.name
    #    user.first_name = auth.info.first_name
    #    user.last_name = auth.info.last_name
    #    user.email = auth.info.email
    #    user.avatar = auth.info.image
    #    user.password = Devise.friendly_token[0,20]
    #  end
      nil
    end
  end

  ####====================================== END AUTHENTICATION METHODS ============================================================

  #return groups using for global permissions
  def group_for_global_permissions
    self.groups.select { |i| i.for_global_permission == true }
  end

  #return groups using for project securities
  def group_for_project_securities
    self.groups.select { |i| i.for_project_security == true }
  end

  # Allow to encrypt password
  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

  #Allow to import user thanks to his login from ldap for the on-the-fly user creation
  def import_user_from_ldap(ldap_cn, login, ldap_server)
    login_filter = Net::LDAP::Filter.eq ldap_server.user_name_attribute, "#{login}"
    object_filter = Net::LDAP::Filter.eq 'objectClass', '*'
    #is_an_automatic_account_activation? ? status = 'active' : status = 'pending'

    search = ldap_cn.search(:base => ldap_server.base_dn,
                            :filter => object_filter & login_filter,
                            :attributes => ['dn', ldap_server.first_name_attribute,
                                            ldap_server.last_name_attribute,
                                            ldap_server.email_attribute,
                                            ldap_server.initials_attribute]) do |entry|

      self.auth_method = AuthMethod.find_by_id(ldap_server.id)
      self.auth_type = ldap_server.id

      if entry["#{ldap_server.email_attribute}"][0].blank?
        return 1
      end

      if entry["#{ldap_server.first_name_attribute}"][0].blank?
        return 2
      end

      if entry["#{ldap_server.last_name_attribute}"][0].blank?
        return 3
      end

      if User.find_by_email(entry["#{ldap_server.email_attribute}"][0])
        return 0
      end

      self.email = entry["#{ldap_server.email_attribute}"][0]
      self.login_name = login.to_s
      self.first_name = entry["#{ldap_server.first_name_attribute}"][0]
      self.last_name = entry["#{ldap_server.last_name_attribute}"][0]
      self.group_ids = Group.find_by_name('Everyone').id
      self.initials = entry["#{ldap_server.initials_attribute}"][0]
      self.time_zone = 'GMT'
      self.save!
    end
  end

  #Allow to import user thanks to his email from ldap for the on-the-fly user creation
  def import_user_from_ldap_mail(ldap_cn, email, ldap_server)
    login_filter = Net::LDAP::Filter.eq ldap_server.email_attribute, "#{email}"
    object_filter = Net::LDAP::Filter.eq 'objectClass', '*'
    #is_an_automatic_account_activation? ? status = 'active' : 'pending'

    search = ldap_cn.search(:base => ldap_server.base_dn,
                            :filter => object_filter & login_filter,
                            :attributes => ['dn', ldap_server.user_name_attribute,
                                            ldap_server.first_name_attribute,
                                            ldap_server.last_name_attribute,
                                            ldap_server.initials_attribute]) do |entry|

      self.auth_method = AuthMethod.find_by_id(ldap_server.id)

      self.auth_type = ldap_server.id

      if entry["#{ldap_server.user_name_attribute}"][0].blank?
        return 4
      end

      if entry["#{ldap_server.first_name_attribute}"][0].blank?
        return 2
      end

      if entry["#{ldap_server.last_name_attribute}"][0].blank?
        return 3
      end

      if User.find_by_login_name(entry["#{ldap_server.user_name_attribute}"][0])
        return 0
      end

      self.login_name = entry["#{ldap_server.user_name_attribute}"][0]
      self.email = email.to_s
      self.first_name = entry["#{ldap_server.first_name_attribute}"][0]
      self.last_name = entry["#{ldap_server.last_name_attribute}"][0]
      self.group_ids = Group.find_by_name('Everyone').id
      self.initials = entry["#{ldap_server.initials_attribute}"][0]
      self.time_zone = 'GMT'
      self.save!
    end
  end

  #def ldap_authentication(password, login)
  #  ldap_cn = Net::LDAP.new(:host => self.auth_method.server_name,
  #                          :base => self.auth_method.base_dn,
  #                          :port => self.auth_method.port.to_i,
  #                          :encryption => self.auth_method.encryption2 ,
  #                          :auth => {
  #                              :method => :simple,
  #                              :username => "#{self.auth_method.user_name_attribute.to_s}=#{self.login_name.to_s},#{self.auth_method.base_dn}",
  #                              :password => password
  #                          })
  #  if ldap_cn.bind
  #    if self.active?
  #      self
  #    else
  #      nil
  #    end
  #  else
  #    nil
  #  end
  #end

  #Override
  def to_s
    self.name
  end

  # Returns "First Name"
  def name
    self.first_name.to_s + ' ' + self.last_name.to_s
  end

  def alias
    self.login_name
  end

  #Load user project securities for selected project id
  def project_securities_for_select(prj_id)
    self.project_securities.select { |i| i.project_id == prj_id &&
                                         i.is_model_permission == true &&
                                         i.is_estimation_permission == false }.first
  end

  def locale
    begin
      self.language.locale.downcase
    rescue
      :en
    end
  end

  private
  def update_associations_for_triggers
    #self.organization_ids_after_last_update = self.organization_ids
    #self.group_ids_after_last_update = self.group_ids

    ###ApplicationController.helpers.save_associations_event_changes(self)


    # puts self.changed?
    # begin
    #   what_changes = self._record_changes
    #   changes_create = self._record_changes_create
    #   changes_delete = self._record_changes_delete
    #   # if self._record_changes_create.changed?
    #   #   puts self._record_changes_create.changes?
    #   # end
    #  rescue
    #   puts "test"
    #  end
  end


end
