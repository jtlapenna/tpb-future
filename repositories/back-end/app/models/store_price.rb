class StorePrice < ApplicationRecord
  belongs_to :store

  validates :name, presence: true, uniqueness: { scope: :store_id }

  scope :owner, lambda { |owner|
    joins(:store).merge(Store.owner(owner))
  }
end

# == Schema Information
#
# Table name: store_prices
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  store_id   :bigint
#
# Indexes
#
#  index_store_prices_on_store_id  (store_id)
#
# Foreign Keys
#
#  fk_rails_...  (store_id => stores.id)
#
