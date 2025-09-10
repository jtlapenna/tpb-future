class PaymentGatewayProvider < ApplicationRecord
end

# == Schema Information
#
# Table name: payment_gateway_providers
#
#  id         :bigint           not null, primary key
#  fields     :string           default([]), is an Array
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
