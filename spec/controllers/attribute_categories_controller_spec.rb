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

  before :each do
    sign_in
    @connected_user = controller.current_user

    @attribute_category = FactoryGirl.create(:quality_in_use)
    @defined_status = FactoryGirl.build(:defined_status)
    @retired_status = FactoryGirl.build(:retired_status)
    @params = { :id => @attribute_category.id }

  end

  describe 'Index' do
    it 'renders the new template' do
      get :index
      response.should render_template('index')
    end
  end

  describe 'New' do
    it 'renders the new template' do
      get :new
      response.should render_template('new')
    end

    it 'assigns a new attribute_category as @attribute_category' do
      get :new
      assigns(:attribute_category).should be_a_new_record
    end
  end

  describe 'GET edit' do
    it 'assigns the requested attribute_category as @attribute_category' do
      get :edit, {:id => @attribute_category.to_param}
      assigns(:attribute_category)==([@attribute_category])
    end
  end


  describe 'create' do
    it 'renders the create template' do
      @params = { :name => 'Software Size', :alias=> 'software_size', :uuid => '1', :custom_value=> 'local'}
      post :create, @params
      response.should be_success
    end
  end

  describe 'DELETE destroy' do

    it 'redirects to the acquisition_category list' do
      @params = { :id => @attribute_category.id }
      delete :destroy, @params
      response.should redirect_to attribute_categories_path
    end
  end

end
