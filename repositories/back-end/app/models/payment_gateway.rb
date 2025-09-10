class PaymentGateway < ApplicationRecord
  belongs_to :store
  belongs_to :payment_gateway_provider
  validate :check_allowed_projects

end
def check_allowed_projects
  if self.projects.blank?
    errors.add(:projects, "Specify at least one project")
  elsif self.projects.detect { |s| !(%w(ECOMMERCE DISPLAYS).include? s) }
    errors.add(:projects, "One of the projects is invalid")
  end
end
# == Schema Information
#
# Table name: payment_gateways
#
#  id                          :bigint           not null, primary key
#  api_settings                :json
#  projects                    :string           default([]), is an Array
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  payment_gateway_provider_id :bigint           not null
#  store_id                    :bigint           not null
#
# Indexes
#
#  index_payment_gateways_on_payment_gateway_provider_id  (payment_gateway_provider_id)
#  index_payment_gateways_on_store_id                     (store_id)
#
# Foreign Keys
#
#  fk_rails_...  (payment_gateway_provider_id => payment_gateway_providers.id)
#  fk_rails_...  (store_id => stores.id)
#
