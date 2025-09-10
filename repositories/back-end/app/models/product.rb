class Product < ApplicationRecord
  include AlgoliaSearch
  include Reviewable

  algoliasearch per_environment: true,
                auto_index: false, auto_remove: false,
                disable_indexing: proc {
                  Rails.env.test? || ENV['ALGOLIASEARCH_DISABLED'] == 'true'
                } do
    attribute :name, :description

    attribute :category do
      { name: category.name, id: category.id }
    end

    searchableAttributes ['name', 'category.name', 'unordered(description)']
  end

  acts_as_taggable
  belongs_to :category
  has_many :product_variants, dependent: :nullify

  has_many :attribute_values, as: :target, inverse_of: :target, dependent: :nullify
  accepts_nested_attributes_for :attribute_values, allow_destroy: true, reject_if: :all_blank

  has_many :attribute_defs, through: :attribute_values

  has_one :video, class_name: 'Asset', as: :source, inverse_of: :source, dependent: :nullify
  accepts_nested_attributes_for :video, allow_destroy: true, reject_if: :all_blank

  has_many :images, as: :imageable, inverse_of: :imageable, dependent: :nullify
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank

  scope :name_like, lambda { |name|
    where('products.name ILIKE :name', name: "%#{name}%")
  }

  scope :with_category, lambda { |category|
    where(category: category)
  }

  # This is to track tags changes and update updated_at
  before_save :track_tags_changes

  validates :name, presence: true

  # Prevent algolia reindex every save
  def will_save_change_to_category?
    will_save_change_to_category_id?
  end

  def video_url
    video&.url
  end

  private

  def track_tags_changes
    new_tags = tag_list.sort
    old_tags = tags.map(&:name).sort

    self.updated_at = Time.zone.now if persisted? && new_tags != old_tags
  end
end

# == Schema Information
#
# Table name: products
#
#  id             :bigint           not null, primary key
#  description    :string
#  is_full_screen :boolean          default(FALSE)
#  name           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  category_id    :bigint
#
# Indexes
#
#  index_products_on_category_id  (category_id)
#  index_products_on_name         (lower((name)::text) varchar_pattern_ops)
#
# Foreign Keys
#
#  fk_rails_...  (category_id => categories.id)
#
