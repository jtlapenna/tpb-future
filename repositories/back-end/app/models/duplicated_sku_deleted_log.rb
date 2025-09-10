class DuplicatedSkuDeletedLog < ApplicationRecord
  belongs_to :store
  belongs_to :store_product
end

# == Schema Information
#
# Table name: duplicated_sku_deleted_logs
#
#  id                       :bigint           not null, primary key
#  deleted_sku              :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  deleted_store_product_id :string
#  store_id                 :bigint
#  store_product_id         :bigint
#
# Indexes
#
#  index_duplicated_sku_deleted_logs_on_store_id          (store_id)
#  index_duplicated_sku_deleted_logs_on_store_product_id  (store_product_id)
#
# Foreign Keys
#  fk_rails_...  (store_id => stores.id)
#  fk_rails_...  (store_product_id => store_products.id)
#
