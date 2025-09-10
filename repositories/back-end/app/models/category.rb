class Category < ApplicationRecord
  has_many :products, dependent: :nullify
  has_many :category_kiosk_layout, dependent: :destroy
  has_many :kiosk_layouts, through: :category_kiosk_layout

  validates :name, presence: true, uniqueness: true
end

# == Schema Information
#
# Table name: categories
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
