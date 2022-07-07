require "rails_helper"

RSpec.describe LivrablesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/livrables").to route_to("livrables#index")
    end

    it "routes to #new" do
      expect(:get => "/livrables/new").to route_to("livrables#new")
    end

    it "routes to #show" do
      expect(:get => "/livrables/1").to route_to("livrables#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/livrables/1/edit").to route_to("livrables#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/livrables").to route_to("livrables#create")
    end

    it "routes to #update" do
      expect(:put => "/livrables/1").to route_to("livrables#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/livrables/1").to route_to("livrables#destroy", :id => "1")
    end

  end
end
