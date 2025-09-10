class ProductLayoutTab < ApplicationRecord
  belongs_to :product_layout

  has_many :elements, class_name: 'ProductLayoutElement',
                      as: :source,
                      inverse_of: :source,
                      dependent: :destroy
  accepts_nested_attributes_for :elements, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true
  validates :order, presence: true, numericality: { only_integer: true }

  scope :sorted, -> { order(order: :asc) }
end

# == Schema Information
#
# Table name: product_layout_tabs
#
#  id                :bigint           not null, primary key
#  name              :string
#  order             :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  product_layout_id :bigint
#
# Indexes
#
#  index_product_layout_tabs_on_product_layout_id  (product_layout_id)
#
# Foreign Keys
#
#  fk_rails_...  (product_layout_id => product_layouts.id)
#
