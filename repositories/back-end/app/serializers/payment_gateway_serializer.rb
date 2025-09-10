class PaymentGatewaySerializer < ActiveModel::Serializer
  attributes :id, :api_settings, :projects  
  has_one :payment_gateway_provider
end
