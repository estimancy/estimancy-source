require 'spec_helper'

describe User do

  before :each do
    @admin1 = FactoryGirl.create(:user)
    @admin = User.new(admin_user_hash)  #defined below
    @user = User.new(valid_user_hash)   #defined below
  end

  it 'should be valid' do
    @admin.should be_valid
    @user.should be_valid
    @admin1.should be_valid
  end

  it 'should return the name of user' do
    @admin1.to_s.should eql(@admin1.name())
  end

  #ATTRIBUTES AND FORMAT VALIDATIONS

  it 'should not be valid without last_name' do
    @user.last_name=''
    @user.should_not be_valid
  end

  it 'should not be valid without first_name' do
    @user.first_name=''
    @user.should_not be_valid
  end

  #Validating login_name
  it 'should not be valid without login_name' do
    @user.login_name=''
    @user.should_not be_valid
  end

  describe 'when login_name is already taken' do

    it 'should not be_valid' do
      #@user_with_same_login = @user
      #@user_with_same_login.should_not be_valid
      u1 = @admin1.dup
      u1.login_name = @admin1.login_name
      u1.save
      u1.should_not be_valid
    end
  end

  #Validating Email address
  it 'should not be valid without email' do
    @user.email =''
    @user.should_not be_valid
  end

  it 'should not be valid when email is nil' do
    @user.email = 'test@moi.fr'
    @user.email.should match(/\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/i)
  end

  it 'should check for email format validation' do
    @user.email =
    @user.should_not have(1).errors_on(:email)
    @user.should_not be_valid
  end

  describe 'when email address is already taken' do

    it 'should not be valid' do
      #@user_with_same_email = @user
      #@user_with_same_email.should_not be_valid

      u1 = @admin1.dup
      u1.email = @admin1.email
      u1.save
      u1.should_not be_valid
    end
  end

  it 'should not be valid without user_status' do
    @admin1.user_status=''
    @admin1.should_not be_valid
  end

  it 'should not be valid without auth_type' do
    @user.auth_type = ''
    @user.should_not be_valid
  end

  it 'should not be valid without password' do
    if @user.auth_method
      @user.password = ''
      @user.should_not be_valid if @user.auth_method.name.include?('Application')
    end
  end

  it 'should not be valid without password_confirmation' do
    if @user.auth_method
      @user.password_confirmation=''
      @user.should_not be_valid  if @user.auth_method.name.include?('Application')
    end
  end

  # This can happen at the Console: because when password_confirmation is 'nil', Rails doesn't run validation
  it 'should not be valid when password confirmation is nil' do
    if @admin.auth_method
      @admin.password_confirmation = nil
      @admin.should_not be_valid if @admin.auth_method.name.include?('Application')
    end
  end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation= 'changed_pass' }
    it 'should not be valid' do
      if @user.auth_method
        @user.should_not be_valid if @user.auth_method.name.include?('Application')
      end
    end
  end

  #it "sends a e-mail" do
  #  @user.send_password_reset()
  #  ActionMailer::Base.deliveries.last.to.should == [@user.email]
  #end
  #describe "when password is too short" do
  #  before do
  #    #password_min_length = AdminSetting.new(:key => "password_min_length", :value => "4")
  #    #password_min_length.save
  #    @user.password = @user.password_confirmation = "abc"
  #  end
  #  it "should not be valid when password is too short" do
  #    @user.password_length.should_not be_valid
  #  end
  #end

  #AUTHENTICATION VALIDATION

  describe 'check if password is not blank' do
    before {@user.password = ''
    }
    it 'should return false' do
      @user.password_present?.should be_false
    end
  end

  describe 'return value of authenticate method' do
    before { @new_user = User.first }

    let(:found_user) { User.find_by_email(@new_user.email) }
    subject {found_user}

    describe 'with valid password' do
      #it { should == User.authenticate(@new_user.login_name, @new_user.password)}
      it { should == User.authenticate(found_user.login_name, 'projestimate')}
    end

    describe 'with invalid password' do
      let(:user_with_invalid_password) { User.authenticate(found_user.login_name, 'invalid') }
      it { should_not == user_with_invalid_password }
      specify { user_with_invalid_password.should be_false}
    end

    describe 'ldap authentication' do
      #@new_user.ldap_authentication("fauxmotdepasse", @new_user.login_name).should be_nil
    end

  end


  #METHODS AND OTHERS VALIDATIONS

  it 'should be activated by admin' do
    @admin.user_status = 'active'
    @admin.user_status.should eql('active')
    @admin.should be_valid
  end

  it 'should be in pending mode waiting for validation' do
    @user.user_status.should eql('pending')
    @user.user_status='pending'
    @user.should be_valid
  end

  #check admin status
  it 'should be in Admin or MasterAdmin groups to be an admin account' do
    first_user = User.first
    group = FactoryGirl.create(:group)
    group.name = 'Admin'
    first_user.groups << group
    first_user.save
    first_user.should have_at_least(1).admin_groups
  end

  it 'should not be an suspending account' do
    @user.user_status.should_not eql('suspending')
    @user.user_status='active'
    @user.should be_valid
  end

  it 'should be blacklisted' do
    @user.user_status='blacklisted'
    @user.should be_valid
  end

  it 'should have a valid name =  first_name + ' ' + last_name' do
    @user.name.should eql(@user.first_name+ ' ' + @user.last_name)
  end


  #AASM STATES

  it 'should initially have user_status as :pending' do
    #@user.user_status = "active"
    @user.user_status.should eql('pending')
  end

  #TODO
  #it "should set user_status to 'active' as default status when admin is the author" do
  #  @user = User.new(:last_name => 'test_last_name', :first_name => 'test_first_name', :login_name => 'test', :email => 'email@test.fr', :user_status => 'pending', :auth_type => 1, :password => 'test', :password_confirmation => 'test')
  #  @user.user_status.should == 'active'
  #end

  describe 'testing user status transition' do
    before do
      @user_copy = @admin1
      @user_copy.user_status = 'pending'
    end
    let(:user2) { @user_copy }

    it "should set user_status to 'active' when transition to :active" do
      user2.user_status = 'pending'
      lambda { user2.switch_to_active! }.should change(user2, :user_status).from('pending').to('active')
      user2.user_status = 'suspended'
      lambda { user2.switch_to_active! }.should change(user2, :user_status).from('suspended').to('active')
      user2.user_status = 'blacklisted'
      lambda { user2.switch_to_active! }.should change(user2, :user_status).from('blacklisted').to('active')
    end

    it "should set user_status to 'suspended' when transition to :suspended" do
      user2.user_status = 'pending'
      lambda { user2.switch_to_suspended! }.should change(user2, :user_status).from('pending').to('suspended')
      user2.user_status = 'active'
      lambda { user2.switch_to_suspended! }.should change(user2, :user_status).from('active').to('suspended')
      user2.user_status = 'blacklisted'
      lambda { user2.switch_to_suspended! }.should change(user2, :user_status).from('blacklisted').to('suspended')
    end

    it "should set user_status to 'blacklisted' when transition to :blacklisted" do
      user2.user_status = 'suspended'
      lambda { user2.switch_to_blacklisted! }.should change(user2, :user_status).from('suspended').to('blacklisted')
      user2.user_status = 'active'
      lambda { user2.switch_to_blacklisted! }.should change(user2, :user_status).from('active').to('blacklisted')
      user2.user_status = 'pending'
      lambda { user2.switch_to_blacklisted! }.should change(user2, :user_status).from('pending').to('blacklisted')
    end

    it 'should set user_status to :pending when transition to :pending' do
      user2.user_status = 'suspended'
      lambda { user2.switch_to_pending! }.should change(user2, :user_status).from('suspended').to('pending')
      user2.user_status = 'active'
      lambda { user2.switch_to_pending! }.should change(user2, :user_status).from('active').to('pending')
      user2.user_status = 'blacklisted'
      lambda { user2.switch_to_pending! }.should change(user2, :user_status).from('blacklisted').to('pending')
    end
  end

  it 'should be have LastName FirstName' do
    @admin.name.should eq('Administrator Projestimate')
  end

  it 'should return groups array (globals permissions)' do
    user_groups = @user.group_for_global_permissions
    user_groups.each do |grp|
      grp.for_global_permission.should eql('true')
    end
  end

  it 'should return groups array (project securities)' do
    user_groups = @user.group_for_project_securities
    user_groups.each do |grp|
      grp.for_project_security.should eql('true')
    end
  end

  it 'should return groups array (specific permissions)' do
  end

  it 'should be authenticate by the application' do
    @admin1.auth_method.name.should match(/Application_\d/)
  end

  #it "should be authenticate by the a LDAP directory" do
  #  if (@user.auth_method.certificate)==true
  #      use_ssl=:simple_tls
  #  else
  #      use_ssl=""
  #  end
  #end

  it 'should return admin group' do
    #@user.admin_groups.should have_at_least(2).items  #Admin and MasterAdmin
    new_user = User.first
    group1 = FactoryGirl.create(:group)
    group1.name = 'Admin'

    group2 = FactoryGirl.create(:group)
    group2.name = 'MasterAdmin'

    new_user.groups << group1
    new_user.groups << group2

    new_user.save
    new_user.admin_groups.should have_at_least(2).items  #Admin and MasterAdmin
  end

  it 'should be an admin if he had admin right' do
  end

  it 'should be delete recent projects' do
  end

  it 'should add recent projects' do
    project1 = FactoryGirl.create(:project)
    @user.add_recent_project(project1.id)
    @user.ten_latest_projects.first.should eql(project1.id)
  end

  it 'should be send password reset' do
    #@user.generate_token(:password_reset_token).should_not be_nil
    #@user.password_reset_sent_at.should eql?(Time.zone.now)
    #@user.save.should be_false
    #UserMailer.forgotten_password(@user).deliver
  end

  it 'should return last projects' do
    user_last_project = @admin1.ten_latest_projects
  end

  it 'should return a search result (using for data-tables plugins)' do
  end


  it "should return '-' if time zone is nil" do
    @user.time_zone=nil
    @user.tz.should eql('UTC')
  end

  it 'should return level name if time zone is not nil' do
    @user.time_zone='fr'
    @user.tz.should eql( @user.time_zone)
  end

  def valid_user_hash
    {:last_name => 'test_last_name', :first_name => 'test_first_name', :login_name => 'test', :email => 'email@test.fr', :user_status => 'pending', :auth_type => 1, :password => 'test_me', :password_confirmation => 'test_me'}
  end


  def admin_user_hash
    {:last_name => 'Projestimate', :first_name => 'Administrator', :login_name => 'administrator', :email => 'admin@yourcompany.net', :user_status => 'active', :auth_type => 6, :password => 'test_me', :password_confirmation => 'test_me'}
  end

end