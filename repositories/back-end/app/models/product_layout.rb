class ProductLayout < ApplicationRecord
  has_many :elements, class_name: 'ProductLayoutElement',
                      as: :source,
                      inverse_of: :source,
                      dependent: :destroy
  accepts_nested_attributes_for :elements, allow_destroy: true, reject_if: :all_blank

  has_many :tabs, class_name: 'ProductLayoutTab', dependent: :destroy
  accepts_nested_attributes_for :tabs, allow_destroy: true, reject_if: :all_blank

  has_many :kiosk_layouts, dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end

# == Schema Information
#
# Table name: product_layouts
#
#  id         :bigint           not null, primary key
#  name       :string
#  stylesheet :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_product_layouts_on_name  (lower((name)::text)) UNIQUE
#
