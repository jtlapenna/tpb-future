require 'rails_helper'

RSpec.describe "CustomerOrders", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/customer_order/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/customer_order/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/customer_order/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/customer_order/destroy"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/customer_order/show"
      expect(response).to have_http_status(:success)
    end
  end

end
