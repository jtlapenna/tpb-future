class CustomerOrder < ApplicationRecord
  ALLOWED_STATUS = %w[VERIFICATION_PENDING AWAITING_PROCESSING IN_PROCESS PACKED_READY OUT_FOR_DELIVERY COMPLETED CANCELED REMOVED]

  belongs_to :store

  validates :customer_id, :order_id, presence: true

  store :data, coder: JSON

  scope :sorted, -> { order created_at: :desc }
end

# == Schema Information
#
# Table name: customer_orders
#
#  id           :bigint           not null, primary key
#  amount       :decimal(, )
#  data         :text
#  printed_date :datetime
#  status       :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  customer_id  :integer
#  order_id     :string
#  printed_id   :string
#  store_id     :bigint
#
# Indexes
#
#  index_customer_orders_on_customer_id  (customer_id)
#  index_customer_orders_on_store_id     (store_id)
#
# Foreign Keys
#
#  fk_rails_...  (store_id => stores.id)
#
