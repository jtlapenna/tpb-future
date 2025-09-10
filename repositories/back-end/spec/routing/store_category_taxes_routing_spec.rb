require "rails_helper"

RSpec.describe StoreCategoryTaxesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/store_category_taxes").to route_to("store_category_taxes#index")
    end

    it "routes to #show" do
      expect(get: "/store_category_taxes/1").to route_to("store_category_taxes#show", id: "1")
    end


    it "routes to #create" do
      expect(post: "/store_category_taxes").to route_to("store_category_taxes#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/store_category_taxes/1").to route_to("store_category_taxes#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/store_category_taxes/1").to route_to("store_category_taxes#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/store_category_taxes/1").to route_to("store_category_taxes#destroy", id: "1")
    end
  end
end
