require "rails_helper"

RSpec.describe PaymentGatewayProvidersController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/payment_gateway_providers").to route_to("payment_gateway_providers#index")
    end

    it "routes to #show" do
      expect(get: "/payment_gateway_providers/1").to route_to("payment_gateway_providers#show", id: "1")
    end


    it "routes to #create" do
      expect(post: "/payment_gateway_providers").to route_to("payment_gateway_providers#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/payment_gateway_providers/1").to route_to("payment_gateway_providers#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/payment_gateway_providers/1").to route_to("payment_gateway_providers#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/payment_gateway_providers/1").to route_to("payment_gateway_providers#destroy", id: "1")
    end
  end
end
