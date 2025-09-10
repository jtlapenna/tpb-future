class StoreCategoryTax < ApplicationRecord
  belongs_to :store_category

  validates :name, presence: true, uniqueness: { scope: :store_category_id }
  validates :value, presence: true

  scope :owner, lambda { |owner|
    joins(:store).merge(Store.owner(owner))
  }
end

# == Schema Information
#
# Table name: store_category_taxes
#
#  id                :bigint           not null, primary key
#  name              :string
#  value             :float
#  store_category_id :bigint
#
# Indexes
#
#  index_store_category_taxes_on_store_category_id  (store_category_id)
#
