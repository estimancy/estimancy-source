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

describe AttributeCategoriesController do

  ## This should return the minimal set of attributes required to create a valid
  ## AttributeCategory. As you add validations to AttributeCategory, be sure to
  ## adjust the attributes here as well.
  #let(:valid_attributes) { { "alias" => "Test" } }
  #
  ## This should return the minimal set of values that should be in the session
  ## in order to pass any filters (e.g. authentication) defined in
  ## AttributeCategoriesController. Be sure to keep this updated too.
  #let(:valid_session) { {} }
  #
  #describe "GET index" do
  #  it "assigns all attribute_categories as @attribute_categories" do
  #    attribute_category = AttributeCategory.create! valid_attributes
  #    get :index, {}, valid_session
  #    assigns(:attribute_categories).should eq([attribute_category])
  #  end
  #end
  #
  #describe "GET show" do
  #  it "assigns the requested attribute_category as @attribute_category" do
  #    attribute_category = AttributeCategory.create! valid_attributes
  #    get :show, {:id => attribute_category.to_param}, valid_session
  #    assigns(:attribute_category).should eq(attribute_category)
  #  end
  #end
  #
  #describe "GET new" do
  #  it "assigns a new attribute_category as @attribute_category" do
  #    get :new, {}, valid_session
  #    assigns(:attribute_category).should be_a_new(AttributeCategory)
  #  end
  #end
  #
  #describe "GET edit" do
  #  it "assigns the requested attribute_category as @attribute_category" do
  #    attribute_category = AttributeCategory.create! valid_attributes
  #    get :edit, {:id => attribute_category.to_param}, valid_session
  #    assigns(:attribute_category).should eq(attribute_category)
  #  end
  #end
  #
  #describe "POST create" do
  #  describe "with valid params" do
  #    it "creates a new AttributeCategory" do
  #      expect {
  #        post :create, {:attribute_category => valid_attributes}, valid_session
  #      }.to change(AttributeCategory, :count).by(1)
  #    end
  #
  #    it "assigns a newly created attribute_category as @attribute_category" do
  #      post :create, {:attribute_category => valid_attributes}, valid_session
  #      assigns(:attribute_category).should be_a(AttributeCategory)
  #      assigns(:attribute_category).should be_persisted
  #    end
  #
  #    it "redirects to the created attribute_category" do
  #      post :create, {:attribute_category => valid_attributes}, valid_session
  #      response.should redirect_to(AttributeCategory.last)
  #    end
  #  end
  #
  #  describe "with invalid params" do
  #    it "assigns a newly created but unsaved attribute_category as @attribute_category" do
  #      # Trigger the behavior that occurs when invalid params are submitted
  #      AttributeCategory.any_instance.stub(:save).and_return(false)
  #      post :create, {:attribute_category => { "name" => "invalid value" }}, valid_session
  #      assigns(:attribute_category).should be_a_new(AttributeCategory)
  #    end
  #
  #    it "re-renders the 'new' template" do
  #      # Trigger the behavior that occurs when invalid params are submitted
  #      AttributeCategory.any_instance.stub(:save).and_return(false)
  #      post :create, {:attribute_category => { "name" => "invalid value" }}, valid_session
  #      response.should render_template("new")
  #    end
  #  end
  #end
  #
  #describe "PUT update" do
  #  describe "with valid params" do
  #    it "updates the requested attribute_category" do
  #      attribute_category = AttributeCategory.create! valid_attributes
  #      # Assuming there are no other attribute_categories in the database, this
  #      # specifies that the AttributeCategory created on the previous line
  #      # receives the :update_attributes message with whatever params are
  #      # submitted in the request.
  #      AttributeCategory.any_instance.should_receive(:update_attributes).with({ "name" => "MyString" })
  #      put :update, {:id => attribute_category.to_param, :attribute_category => { "name" => "MyString" }}, valid_session
  #    end
  #
  #    it "assigns the requested attribute_category as @attribute_category" do
  #      attribute_category = AttributeCategory.create! valid_attributes
  #      put :update, {:id => attribute_category.to_param, :attribute_category => valid_attributes}, valid_session
  #      assigns(:attribute_category).should eq(attribute_category)
  #    end
  #
  #    it "redirects to the attribute_category" do
  #      attribute_category = AttributeCategory.create! valid_attributes
  #      put :update, {:id => attribute_category.to_param, :attribute_category => valid_attributes}, valid_session
  #      response.should redirect_to(attribute_category)
  #    end
  #  end
  #
  #  describe "with invalid params" do
  #    it "assigns the attribute_category as @attribute_category" do
  #      attribute_category = AttributeCategory.create! valid_attributes
  #      # Trigger the behavior that occurs when invalid params are submitted
  #      AttributeCategory.any_instance.stub(:save).and_return(false)
  #      put :update, {:id => attribute_category.to_param, :attribute_category => { "name" => "invalid value" }}, valid_session
  #      assigns(:attribute_category).should eq(attribute_category)
  #    end
  #
  #    it "re-renders the 'edit' template" do
  #      attribute_category = AttributeCategory.create! valid_attributes
  #      # Trigger the behavior that occurs when invalid params are submitted
  #      AttributeCategory.any_instance.stub(:save).and_return(false)
  #      put :update, {:id => attribute_category.to_param, :attribute_category => { "name" => "invalid value" }}, valid_session
  #      response.should render_template("edit")
  #    end
  #  end
  #end
  #
  #describe "DELETE destroy" do
  #  it "destroys the requested attribute_category" do
  #    attribute_category = AttributeCategory.create! valid_attributes
  #    expect {
  #      delete :destroy, {:id => attribute_category.to_param}, valid_session
  #    }.to change(AttributeCategory, :count).by(-1)
  #  end
  #
  #  it "redirects to the attribute_categories list" do
  #    attribute_category = AttributeCategory.create! valid_attributes
  #    delete :destroy, {:id => attribute_category.to_param}, valid_session
  #    response.should redirect_to(attribute_categories_url)
  #  end
  #end

  before :each do
    @attribute_category = FactoryGirl.create(:quality_in_use)
    @defined_status = FactoryGirl.build(:defined_status)
    @retired_status = FactoryGirl.build(:retired_status)
    @params = { :id => @attribute_category.id }

  end


  describe "Index" do
    it "renders the new template" do
      get :index
      response.should render_template("index")
    end
  end

  describe "New" do
    it "renders the new template" do
      get :new
      response.should render_template("new")
    end
    it "assigns a new attribute_category as @attribute_category" do
      get :new
      assigns(:attribute_category).should be_a_new_record
    end
  end

  describe "GET edit" do
    it "assigns the requested attribute_category as @attribute_category" do
      get :edit, {:id => @attribute_category.to_param}
      assigns(:attribute_category)==([@attribute_category])
    end
  end


  describe "create" do
    it "renders the create template" do
      @params = { :name => "Software Size", :alias=>"software_size", :uuid => "1", :custom_value=>"local" }
      post :create, @params
      response.should be_success
    end
  end

  describe "PUT update" do
    before :each do
      @new_ac =  FactoryGirl.create(:product_quality)
    end

    #context "with valid params" do
    #  it "updates the requested activity_category" do
    #    put :update, id: @new_ac, attribute_category: FactoryGirl.attributes_for(:product_quality)
    #    response.should be_success
    #  end
    #end
  end

  describe "DELETE destroy" do
    #it "destroys the requested @acquisition_category" do
    #    @params = { :id => @acquisition_category.id }
    #    delete :destroy, @params
    #    response.should be_success
    #end

    it "redirects to the acquisition_category list" do
      @params = { :id => @attribute_category.id }
      delete :destroy, @params
      response.should redirect_to attribute_categories_path
    end
  end

end
