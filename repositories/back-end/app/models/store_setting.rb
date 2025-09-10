class StoreSetting < ApplicationRecord

  belongs_to :store, inverse_of: :settings

  has_one :background_media, class_name: 'Asset',
                             as: :source,
                             inverse_of: :source,
                             dependent: :nullify

  accepts_nested_attributes_for :background_media, allow_destroy: true, reject_if: :all_blank

  has_many :purchase_limits, dependent: :destroy

  accepts_nested_attributes_for :purchase_limits, allow_destroy: true, reject_if: :all_blank

  store :data, accessors: %i[
    admin_email printer_location pos_location main_color secondary_color
    featured_products_on_top_for_brands_page featured_products_on_top_for_effects_and_uses_page
    featured_products_on_top_for_products_page idle_delay restart_delay service_worker_log
    default_product_description heap_id dispensary_license_number disable_tax_message rfid_popup_setting
    lat lng global_ad_enabled show_thc_cbd_values t_a_c enable_request_tax enable_toggle_tax use_master_category show_alternative_flower_icon checkout_message printer_mac_address use_total_thc default_toggle_customer_type
  ], coder: JSON
end

# == Schema Information
#
# Table name: store_settings
#
#  id         :bigint           not null, primary key
#  data       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  store_id   :integer
#
# Indexes
#
#  index_store_settings_on_store_id  (store_id)
#
# Foreign Keys
#
#  fk_rails_...  (store_id => stores.id)
#
