class ProductLayoutElement < ApplicationRecord
  enum element_type: { medium: 0, dot: 1, text: 2 }

  belongs_to :source, polymorphic: true

  has_many :product_layout_values, dependent: :destroy

  validates :element_type, :coord_x, :coord_y, presence: true

  scope :for_layout, lambda { |product_layout|
    where(source_id: product_layout, source_type: :ProductLayout)
      .or(
        where(
          source_id: ProductLayoutTab.where(product_layout: product_layout),
          source_type: :ProductLayoutTab
        )
      )
  }
end

# == Schema Information
#
# Table name: product_layout_elements
#
#  id           :bigint           not null, primary key
#  coord_x      :string
#  coord_y      :string
#  element_type :integer
#  hint         :string
#  source_type  :string
#  width        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  source_id    :bigint
#
# Indexes
#
#  index_product_layout_elements_on_source_type_and_source_id  (source_type,source_id)
#
