require 'spec_helper'
describe PermissionsController do
  before :each do
    login_as_admin
  end
  describe "GET index" do
    it "renders the index template" do
      get :index
      response.should render_template("index")
    end
  end
end