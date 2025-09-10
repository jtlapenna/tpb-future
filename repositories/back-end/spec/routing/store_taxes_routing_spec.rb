require "rails_helper"

RSpec.describe StoreTaxesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/store_taxes").to route_to("store_taxes#index")
    end

    it "routes to #show" do
      expect(get: "/store_taxes/1").to route_to("store_taxes#show", id: "1")
    end


    it "routes to #create" do
      expect(post: "/store_taxes").to route_to("store_taxes#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/store_taxes/1").to route_to("store_taxes#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/store_taxes/1").to route_to("store_taxes#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/store_taxes/1").to route_to("store_taxes#destroy", id: "1")
    end
  end
end
