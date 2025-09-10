class ProductLayoutValue < ApplicationRecord
  belongs_to :product_layout_element
  belongs_to :kiosk_product, touch: true

  has_one :asset, as: :source, inverse_of: :source, dependent: :destroy
  accepts_nested_attributes_for :asset, allow_destroy: true, reject_if: :all_blank

  delegate :medium?,
           :dot?,
           :text?,
           :source,
           to: :product_layout_element,
           prefix: :element,
           allow_nil: true
  delegate :coord_x, :coord_y, :width, to: :product_layout_element, allow_nil: true

  validates :link, presence: true, if: :element_dot?
  validates :content, presence: true, if: :element_text?
  validates :asset, presence: true, if: :element_medium?

  scope :for_kiosk, ->(kiosk) { joins(:kiosk_product).merge(KioskProduct.where(kiosk_id: kiosk)) }
  scope :for_layout, lambda { |product_layout|
    joins(:product_layout_element)
      .merge(ProductLayoutElement.for_layout(product_layout))
  }
end

# == Schema Information
#
# Table name: product_layout_values
#
#  id                        :bigint           not null, primary key
#  content                   :text
#  link                      :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  kiosk_product_id          :bigint
#  product_layout_element_id :bigint
#
# Indexes
#
#  index_product_layout_values_on_kiosk_product_id           (kiosk_product_id)
#  index_product_layout_values_on_product_layout_element_id  (product_layout_element_id)
#
# Foreign Keys
#
#  fk_rails_...  (kiosk_product_id => kiosk_products.id)
#  fk_rails_...  (product_layout_element_id => product_layout_elements.id)
#
