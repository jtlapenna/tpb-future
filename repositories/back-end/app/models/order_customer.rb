class OrderCustomer < ApplicationRecord
    attr_accessor :products
    validates :kiosks_id, :first_name, :last_name, :amount, presence: true
    validates :uuid, :client_id, presence: false
end
# == Schema Information
#
# Table name: order_customers
#
#  id         :bigint           not null, primary key
#  amount     :decimal(10, 2)
#  date       :datetime
#  first_name :string           not null
#  last_name  :string           not null
#  payed      :boolean          not null
#  uuid       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  client_id  :integer          not null
#  kiosks_id  :bigint
#
# Indexes
#
#  index_order_customers_on_kiosks_id  (kiosks_id)
#
# Foreign Keys
#
#  fk_rails_...  (kiosks_id => kiosks.id)
#