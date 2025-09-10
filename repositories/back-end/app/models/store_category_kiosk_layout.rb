class StoreCategoryKioskLayout < ApplicationRecord
  belongs_to :store_category
  belongs_to :kiosk_layout
end

# == Schema Information
#
# Table name: store_category_kiosk_layouts
#
#  id                :bigint           not null, primary key
#  order             :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  kiosk_layout_id   :bigint           not null
#  store_category_id :bigint           not null
#
# Indexes
#
#  index_store_category_kiosk_layouts_on_kiosk_layout_id    (kiosk_layout_id)
#  index_store_category_kiosk_layouts_on_store_category_id  (store_category_id)
#
# Foreign Keys
#
#  fk_rails_...  (kiosk_layout_id => kiosk_layouts.id)
#  fk_rails_...  (store_category_id => store_categories.id)
#
