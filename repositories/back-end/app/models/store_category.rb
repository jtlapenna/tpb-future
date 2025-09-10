class StoreCategory < ApplicationRecord
  belongs_to :store

  has_many :store_products, dependent: :nullify
  has_many :rfid_products, dependent: :destroy, as: :rfid_entity
  has_many :store_category_taxes, dependent: :nullify
  has_many :kiosk_layouts
  accepts_nested_attributes_for :store_category_taxes, allow_destroy: true

  has_one :banner, class_name: 'Asset', as: :source, inverse_of: :source, dependent: :destroy
  accepts_nested_attributes_for :banner, allow_destroy: true, reject_if: :all_blank

  has_and_belongs_to_many :purchase_limits # rubocop:disable Rails/HasAndBelongsToMany
  has_and_belongs_to_many :brand_and_store_categories # rubocop:disable Rails/HasAndBelongsToMany

  validate :valid_name
  def valid_name
    if name.blank?
      errors.add(:name, "name can't be blank")
    elsif store.api_type_treez? && has_duplicate_one?
      errors.add(:name, "A category with same name already exist")
    end
  end
  def has_duplicate_one?
    store.store_categories.where.not(id: self).where('lower(name) = ?', name.downcase).count > 0
  end

  scope :owner, lambda { |owner|
    joins(:store).merge(Store.owner(owner))
  }

  scope :name_like, ->(name) { where("#{StoreCategory.table_name}.name ilike ?", "%#{name}%") }
  scope :name_lower, ->(name) { where("lower(#{StoreCategory.table_name}.name) = ?", name.to_s.downcase) }

  scope :name_equal, ->(name) { where("#{StoreCategory.table_name}.name ilike ?", name) }
end

# == Schema Information
#
# Table name: store_categories
#
#  id         :bigint           not null, primary key
#  name       :string
#  order      :integer
#  tax        :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  store_id   :bigint
#
# Indexes
#
#  index_store_categories_on_store_id  (store_id)
#
# Foreign Keys
#
#  fk_rails_...  (store_id => stores.id)
#
