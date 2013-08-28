# This module is used to avoid login repetition while testing controller methods


module ControllerMacros

  def http_login
    user = 'admin'
    pw = 'projestimate'
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user,pw)
    @request.env["HTTP_AUTHORIZATION"] = "Basic " + Base64::encode64("username:password")
  end


  def should_authorize(action, subject)
    controller.should_receive(:authorize!).with(action, subject).and_return('passed!')
    controller.should_receive(:can?).with(action, subject).and_return(true)
  end


  #def mock_user(type, stubs={})
  #  mock_model(type, stubs).as_null_object
  #end

  #def mock_user(stubs={})
  #  @mock_user ||= mock_model(User, stubs).as_null_object
  #end
  #
  #
  #
  ## Example usage: login mock_user(Editor)
  #def login_inn(user)
  #  request.env['warden'] = mock(Warden,
  #                               :authenticate => user,
  #                               :authenticate! => user)
  #end



  def login_as_admin
    #we create other record status
    defined_record_status = RecordStatus.find_or_create_by_name(:name => "Defined", :description => "Test Saly")

    proposed_status = RecordStatus.find_or_create_by_name(:name => "Proposed", :description => "tbd", :record_status_id => defined_record_status.id)
    custom_status = RecordStatus.find_or_create_by_name(:name => "Custom", :description => "tbd", :record_status_id => defined_record_status.id)
    draft_status = RecordStatus.find_or_create_by_name(:name => "Draft", :description => "tbd", :record_status_id => defined_record_status.id)
    retired_status = RecordStatus.find_or_create_by_name(:name => "Retired", :description => "tbd", :record_status_id => defined_record_status.id)
    inReview_status = RecordStatus.find_or_create_by_name(:name => "InReview", :description => "tbd", :record_status_id => defined_record_status.id)
    local_status = RecordStatus.find_or_create_by_name(:name => "Local", :description => "tbd", :record_status_id => defined_record_status.id)

    first_language = Language.first
    if first_language.nil?
      first_language = Language.new(:name => "English", :locale => "EN", :record_status_id => defined_record_status.id)
      first_language.save
    end

    first_auth_method = AuthMethod.first
    if first_auth_method.nil?
      first_auth_method = AuthMethod.new(:name => "Application", :server_name => "Not used", :port => 0, :record_status_id => defined_record_status.id)
      first_auth_method.save
    end

    #user = User.new(:first_name => "Projestimate", :last_name => "Administrator", :login_name => "Admin", :email => "admin@example.com", :password => "secret", :password_confirmation => "secret", :language_id => first_language.id, :auth_type => first_auth_method.id, :user_status=>"active")
    ###user = User.find_or_create_by_login_name(:first_name => "Projestimate", :last_name => "Administrator", :login_name => "admin", :email => "admin@example.com", :password => "secret1234", :password_confirmation => "secret1234", :language_id => first_language.id, :auth_type => first_auth_method.id, :user_status=>"active")
    @user = User.first
    if @user.nil?
      @user = User.find_or_create_by_login_name(:first_name => "Projestimate", :last_name => "Administrator", :login_name => "admin", :email => "youremail@yourcompany.net", :password => "projestimate", :password_confirmation => "projestimate", :language_id => first_language.id, :auth_type => first_auth_method.id, :user_status=>"active")
      @user.save
    end
    session[:current_user_id] = @user.id
    current_user = @user
    controller.stub(:current_user) { @user }   #view.stub(:current_user) { user}
  end

  #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  def login_admin
    @logged_in_user = FactoryGirl.create(:logged_in_admin)

    @controller.stub!(:current_user).and_return(@logged_in_user)
    @logged_in_user
  end


  def logout_admin
    @logged_in_user = nil
    @controller.stub!(:current_user).and_return(@logged_in_user)
    @logged_in_user
  end

  def login_test_me
    @logged_in_user = FactoryGirl.create(:logged_in_admin)
    page.driver.post sessions_path,
                     :user => {:login_name => @logged_in_user.login_name, :password => @logged_in_user.password}
  end
  #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  def first_language
    first_language = Language.first
    if first_language.nil?
      first_language = Language.new(:name => "English", :locale => "EN", :record_status_id => defined_record_status.id)
      first_language.save
    end
    first_language
  end

  def first_auth_method
    first_auth_method = AuthMethod.first
    if first_auth_method.nil?
      first_auth_method = AuthMethod.new(:name => "Application", :server_name => "Not used", :port => 0, :record_status_id => defined_record_status.id)
      first_auth_method.save
    end
    first_auth_method
  end

  def login_user(options = {})
    language = first_language
    auth_method = first_auth_method
    options = {:first_name => "Projestimate_test", :last_name => "Administrator_test", :login_name => "admin_test", :email => "admin_test@example.com", :password => "secret1234", :password_confirmation => "secret1234", :language_id => language.id, :auth_type => auth_method.id, :user_status=>"active"}

    @logged_in_user = Factory.create(:user, options)
    @controller.stub!(:current_user).and_return(@logged_in_user)
    @logged_in_user
  end

  def login_test(options = {})
    #options[:admin] = true
    language = first_language
    auth_method = first_auth_method
    options = {:first_name => "Projestimate_test", :last_name => "Administrator_test", :login_name => "admin_test", :email => "admin_test@example.com", :password => "secret1234", :password_confirmation => "secret1234", :language_id => language.id, :auth_type => auth_method.id, :user_status=>"active"}

    @logged_in_user = Factory.create(:user, options)
    @controller.stub!(:current_user).and_return(@logged_in_user)
    @logged_in_user
  end



  #def login_as_admin
  #  before :each do
  #    @request.env["devise.mapping"] = Devise.mappings[:user]
  #    auth_method = FactoryGirl.create(:auth_method)
  #    language = FactoryGirl.create(:en_language)
  #    user = FactoryGirl.create(:user, :first_name => "Administrator", :last_name => "Projestimate", :initials => "ad", :login_name => "admin", :email => "admin@gmail.com", :user_status => "active", :auth_method => auth_method, :language => language)
  #    sign_in user
  #  end
  #end


  #def log_user
  #  auth_method = FactoryGirl.create(:auth_method)
  #  language = FactoryGirl.create(:en_language)
  #  user = FactoryGirl.create(:user, :first_name => "Administrator", :last_name => "Projestimate", :initials => "ad", :login_name => "admin", :email => "admin@gmail.com", :user_status => "active", :auth_method => auth_method, :language => language)
  #  User.anonymous
  #  get "/dashbord"
  #  assert_equal nil, session[:user_id]
  #  assert_response :success
  #  assert_template "account/login"
  #  post "/dashbord", :login_name =>user.login_name, :password => user.password
  #  assert_equal login, User.find(session[:user_id]).login
  #end
  #def login_as_user
  #  before :each do
  #    #@request.env["devise.mapping"] = Devise.mappings[:user]
  #    @user = FactoryGirl.create(:user)
  #    sign_in @user
  #  end
  #end



#def login_as_user!
#  before do
#    auth_method = FactoryGirl.create(:auth_method)
#    language = FactoryGirl.create(:en_language)
#    user = FactoryGirl.create(:user, :auth_method => auth_method, :language => language)
#
#    #user = User.first
#    @current_user = user
#    controller.stub!(:current_user).and_return(@current_user)
#    session[:user_id] = @current_user.id
#  end
#end

#def login_as_admin!
#  before :each do
#    auth_method = FactoryGirl.create(:auth_method, :name => "Application")
#    language = FactoryGirl.create(:en_language)
#    user=FactoryGirl.create(:user, :first_name => "Administrator", :last_name => "Projestimate", :initials => "ad", :login_name => "admin", :email => "admin@gmail.com", :user_status => "active")
#    @current_user = user
#    controller.stub!(:current_user).and_return(@current_user)
#    session[:user_id] = @current_user.id
#  end
#end

end