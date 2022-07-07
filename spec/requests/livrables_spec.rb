require 'rails_helper'

RSpec.describe "Livrables", :type => :request do
  describe "GET /livrables" do
    it "works! (now write some real specs)" do
      get livrables_path
      expect(response.status).to be(200)
    end
  end
end
