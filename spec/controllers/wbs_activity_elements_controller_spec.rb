require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe WbsActivityElementsController do

  before do
    @connected_user = login_as_admin
  end

  before :each do
    #@wbs_activity=  FactoryGirl.create(:wbs_activity)
    #@wbs_activity_element = FactoryGirl.create(:wbs_activity_element, :wbs_activity_id => @wbs_activity.id)
  end

    # This should return the minimal set of attributes required to create a valid
  # WbsActivityElement. As you add validations to WbsActivityElement, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { 'name' => 'wbs_ac_element_1', 'uuid' => 'MyString', 'description' => 'TBD', 'wbs_activity_id' => 2 }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # WbsActivityElementsController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  #describe "GET show" do
  #  it "assigns the requested wbs_activity_element as @wbs_activity_element" do
  #    wbs_activity_element = FactoryGirl.create(:wbs_activity_element)   #WbsActivityElement.create! valid_attributes
  #    wbs_activity = wbs_activity_element.wbs_activity
  #    get :show, id: wbs_activity
  #    assigns(:wbs_activity).should eq(wbs_activity)
  #  end
  #end
  #
  #describe "GET new" do
  #  it "assigns a new wbs_activity_element as @wbs_activity_element" do
  #    get :new, {}, valid_session
  #    assigns(:wbs_activity_element).should be_a_new(WbsActivityElement)
  #  end
  #end
  #
  #describe "GET edit" do
  #  it "assigns the requested wbs_activity_element as @wbs_activity_element" do
  #    wbs_activity_element = WbsActivityElement.create! valid_attributes
  #    get :edit, {:id => wbs_activity_element.to_param}, valid_session
  #    assigns(:wbs_activity_element).should eq(wbs_activity_element)
  #  end
  #end
  #
  #describe "POST create" do
  #  context "with valid params" do
  #    it "creates a new WbsActivityElement" do
  #      expect {
  #        #post :create, {:wbs_activity_element => valid_attributes}, valid_session
  #        post :create, wbs_activity_element: FactoryGirl.attributes_for(:wbs_activity_element)
  #      }.to change(WbsActivityElement, :count).by(1)
  #    end
  #
  #    it "assigns a newly created wbs_activity_element as @wbs_activity_element" do
  #      post :create, {:wbs_activity_element => valid_attributes}, valid_session
  #      assigns(:wbs_activity_element).should be_a(WbsActivityElement)
  #      assigns(:wbs_activity_element).should be_persisted
  #    end
  #
  #    it "redirects to the created wbs_activity_element" do
  #      post :create, {:wbs_activity_element => valid_attributes}, valid_session
  #      response.should be_success   ##response.should redirect_to(WbsActivityElement.last)
  #    end
  #  end
  #
  #  describe "with invalid params" do
  #    it "assigns a newly created but unsaved wbs_activity_element as @wbs_activity_element" do
  #      # Trigger the behavior that occurs when invalid params are submitted
  #      WbsActivityElement.any_instance.stub(:save).and_return(false)
  #      post :create, {:wbs_activity_element => { "uuid" => "invalid value" }}, valid_session
  #      assigns(:wbs_activity_element).should be_a_new(WbsActivityElement)
  #    end
  #
  #    it "re-renders the 'new' template" do
  #      # Trigger the behavior that occurs when invalid params are submitted
  #      WbsActivityElement.any_instance.stub(:save).and_return(false)
  #      post :create, {:wbs_activity_element => { "uuid" => "invalid value" }}, valid_session
  #      response.should render_template("new")
  #    end
  #  end
  #end

  #describe "PUT update" do
  #  describe "with valid params" do
  #    it "updates the requested wbs_activity_element" do
  #      wbs_activity_element = WbsActivityElement.create! valid_attributes
  #      # Assuming there are no other wbs_activity_elements in the database, this
  #      # specifies that the WbsActivityElement created on the previous line
  #      # receives the :update_attributes message with whatever params are
  #      # submitted in the request.
  #      WbsActivityElement.any_instance.should_receive(:update_attributes).with({ "uuid" => "MyString" })
  #      put :update, {:id => wbs_activity_element.to_param, :wbs_activity_element => { "uuid" => "MyString" }}, valid_session
  #    end
  #
  #    it "assigns the requested wbs_activity_element as @wbs_activity_element" do
  #      wbs_activity_element = WbsActivityElement.create! valid_attributes
  #      put :update, {:id => wbs_activity_element.to_param, :wbs_activity_element => valid_attributes}, valid_session
  #      assigns(:wbs_activity_element).should eq(wbs_activity_element)
  #    end
  #
  #    it "redirects to the wbs_activity_element" do
  #      wbs_activity_element = WbsActivityElement.create! valid_attributes
  #      put :update, {:id => wbs_activity_element.to_param, :wbs_activity_element => valid_attributes}, valid_session
  #      response.should redirect_to(wbs_activity_element)
  #    end
  #  end

  #  describe "with invalid params" do
  #    it "assigns the wbs_activity_element as @wbs_activity_element" do
  #      wbs_activity_element = WbsActivityElement.create! valid_attributes
  #      # Trigger the behavior that occurs when invalid params are submitted
  #      WbsActivityElement.any_instance.stub(:save).and_return(false)
  #      put :update, {:id => wbs_activity_element.to_param, :wbs_activity_element => { "uuid" => "invalid value" }}, valid_session
  #      assigns(:wbs_activity_element).should eq(wbs_activity_element)
  #    end
  #
  #    it "re-renders the 'edit' template" do
  #      wbs_activity_element = WbsActivityElement.create! valid_attributes
  #      # Trigger the behavior that occurs when invalid params are submitted
  #      WbsActivityElement.any_instance.stub(:save).and_return(false)
  #      put :update, {:id => wbs_activity_element.to_param, :wbs_activity_element => { "uuid" => "invalid value" }}, valid_session
  #      response.should render_template("edit")
  #    end
  #  end
  #end

  #describe "DELETE destroy" do
  #  it "destroys the requested wbs_activity_element" do
  #    wbs_activity_element = WbsActivityElement.create! valid_attributes
  #    expect {
  #      delete :destroy, {:id => wbs_activity_element.to_param}, valid_session
  #    }.to change(WbsActivityElement, :count).by(-1)
  #  end
  #
  #  it "redirects to the wbs_activity_elements list" do
  #    wbs_activity_element = WbsActivityElement.create! valid_attributes
  #    delete :destroy, {:id => wbs_activity_element.to_param}, valid_session
  #    response.should redirect_to(wbs_activity_elements_url)
  #  end
  #end

end
