class Brand < ApplicationRecord
  has_many :rfid_products, dependent: :destroy, as: :rfid_entity
  has_many :ad_banners, dependent: :nullify, as: :advertisable
  validates :name, presence: true, uniqueness: true

  has_one :logo, as: :source, inverse_of: :source, class_name: 'Asset', dependent: :nullify
  accepts_nested_attributes_for :logo, allow_destroy: true, reject_if: :all_blank

  has_many :product_variants, dependent: :nullify

    scope :containing_text, lambda { |name|
    query = "#{Brand.arel_table.name}.name ILIKE :name OR "
    query += "#{Brand.arel_table.name}.description ILIKE :name"

    where(query, name: "%#{name}%")
  }

  scope :name_equal, lambda { |name|
    where("replace(lower(#{Brand.table_name}.name), ' ', '') = replace(lower(?), ' ', '')", name)
  }
  
   def store_count
    StoreProduct.where(product_variant: product_variants).collect(&:store_id).uniq.count
  end
end

# == Schema Information
#
# Table name: brands
#
#  id          :bigint           not null, primary key
#  description :string
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_brand_on_name_case_space_insensitive  (replace(lower((name)::text), ' '::text, ''::text))
#
