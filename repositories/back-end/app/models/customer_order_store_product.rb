class CustomerOrderStoreProduct < ApplicationRecord
    attr_accessor :kiosks_id, :first_name, :last_name, :amount, :uuid, :payed, :date, :client_id
    validates :order_customers_id, :store_products_id, :product_value_id, :quantity, presence: true 
end

# == Schema Information
#
# Table name: customer_order_store_products
#
#  id                 :bigint           not null, primary key
#  quantity           :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  order_customers_id :bigint
#  product_value_id   :integer
#  store_products_id  :bigint
#
# Indexes
#
#  index_customer_order_store_products_on_order_customers_id  (order_customers_id)
#  index_customer_order_store_products_on_store_products_id   (store_products_id)
#
# Foreign Keys
#
#  fk_rails_...  (order_customers_id => order_customers.id)
#  fk_rails_...  (store_products_id => store_products.id)
#
