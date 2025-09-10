class PurchaseLimit < ApplicationRecord
  belongs_to :store_setting
  has_and_belongs_to_many :store_categories # rubocop:disable Rails/HasAndBelongsToMany

  validates :limit, presence: true, numericality: { greater_than: 0, only_integer: true, allow_blank: true }
  validates :store_categories, presence: true
end

# == Schema Information
#
# Table name: purchase_limits
#
#  id               :bigint           not null, primary key
#  limit            :integer          not null
#  name             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  store_setting_id :bigint
#
# Indexes
#
#  index_purchase_limits_on_store_setting_id  (store_setting_id)
#
# Foreign Keys
#
#  fk_rails_...  (store_setting_id => store_settings.id)
#
